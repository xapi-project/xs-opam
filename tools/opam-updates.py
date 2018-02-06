#!/usr/bin/env python
from __future__ import print_function

from itertools import chain, takewhile
from netrc import netrc, NetrcParseError
from subprocess import call, check_output, CalledProcessError

import argparse
import os
import sys
import shutil

try:
    import requests
except ImportError:
    sys.exit("The `requests` package needs to be installed. Aborting.")


class Package:
    "Opam package, contains name, current version and an optional new version."

    def __init__(self, name, cur=None, new=None):
        self.name = name
        if cur is None and new is None:
            raise ValueError("At least one of cur and new has to be present.")
        self.cur = cur
        self.new = new

    @property
    def github_api_url(self):
        "GitHub API url for the opam package folder content."
        path = "packages/{name}/{name}.{version}".format(
            name=self.name,
            version=self.new if self.new is not None else self.cur)
        return "https://api.github.com/repos/ocaml/opam-repository/contents/{}".format(path)

    @property
    def current_name(self):
        "Return name.current_version"
        return "{}.{}".format(self.name, self.cur)

    @property
    def new_name(self):
        "Return name.new_version"
        return "{}.{}".format(self.name, self.new)

    def current_path(self, prefix):
        "Path of the current version based on [prefix]"
        return os.path.join(prefix, self.current_name)

    def new_path(self, prefix):
        "Path of the new version based on [prefix]"
        return os.path.join(prefix, self.new_name)

    def path(self, prefix):
        """
        Path of the new version based on [prefix] if present,
        otherwise current path.
        """
        if self.new is not None:
            return self.new_path(prefix)
        return self.current_path(prefix)


def download(session, url, file_path):
    "Download the file at [url] in [file_path]."
    r = session.get(url)
    r.raise_for_status()
    with open(file_path, 'wb') as f:
        f.write(r.content)
        f.flush()


def update_files(session, auth, package, prefix):
    """
    Lookup the opam files for the [package], and update them in the
    appropriate subfolder in [prefix].
    """
    base_url = package.github_api_url

    r = session.get(base_url, auth=auth)
    r.raise_for_status()
    entries = r.json()

    for entry in entries:
        if entry["type"] == "dir":
            continue
        new_path = os.path.join(package.path(prefix), entry["name"])
        download(session, entry["download_url"], new_path)

    if any(entry["type"] == "dir"
           and entry["name"] == "files"
           for entry in entries):
        r = session.get(os.path.join(base_url, "files"), auth=auth)
        r.raise_for_status()
        entries = r.json()
        prefix = os.path.join(package.path(prefix), "files")
        os.makedirs(prefix, exist_ok=True)

        for entry in entries:
            if entry["type"] == "dir":
                continue
            new_path = os.path.join(package.path(prefix), entry["name"])
            download(session, entry["download_url"], new_path)


def extract_upgrade(row):
    "Extract upgraded packages from a row in the opam output."
    name, cur, _, new = row.strip().split()[2:6]
    return Package(name, cur, new)


def extract_update(row):
    "Extract updated packages from a row in the opam output."
    name, ver = row.strip().split()[2:4]
    return Package(name, cur=ver)


def extract_install(row):
    "Extract newly installed packages from a row in the opam output."
    name, ver = row.strip().split()[2:4]
    return Package(name, new=ver)


def print_update_actions(upgrades, updates, new_packages):
    """
    Action pretty printer.
    """
    if upgrades:
        print("Upgrades:")
        for pkg in upgrades:
            print("\t- {}: {}->{}".format(pkg.name, pkg.cur, pkg.new))
        print()

    if updates:
        print("Updates (changed upstream):")
        for pkg in updates:
            print("\t- {} {}".format(pkg.name, pkg.cur))
        print()

    if new_packages:
        print("New dependencies:")
        for pkg in new_packages:
            print("\t- {} {}".format(pkg.name, pkg.new))
        print()


def get_opam_upgrade_output():
    """
    Returns the output of `opam upgrade` (executed in dry mode) after
    adding the upstream opam remote to the remotes.
    """
    call("opam remote add upstream https://opam.ocaml.org".split(' '))

    try:
        opam_out = check_output("opam upgrade --dry-run -y".split(' '))
    except CalledProcessError as err:
        sys.exit(err.output)

    filtered_out = takewhile(
        lambda s: "=====" not in s,
        opam_out.split('\n'))

    return list(filtered_out)


# Argument parsing

class AuthAction(argparse.Action):
    """
    Argparse type action for auth command line arguments of the form:
       USER:PASSWORD
    Returns a (USER, PASSWORD) tuple if successful, otherwise raises
    ArgumentTypeError.
    """

    def __call__(self, parser, namespace, values, option_string=None):
        auth = tuple(values.split(':', 1))

        if len(auth) != 2:
            msg = "malformed auth passed to --auth: %r" % values
            raise argparse.ArgumentTypeError(msg)

        setattr(namespace, self.dest, auth)


def get_netrc_auth():
    "Try to get the right auth from netrc."
    try:
        login, _, password = netrc().authenticators("github.com")
        return [(login, password)]
    except (IOError, ValueError, NetrcParseError):
        return []


def parse_args_or_exit(argv=None):
    """
    Parse command line options.
    """
    parser = argparse.ArgumentParser(
        description="xs-opam package upgrade tool")

    parser.add_argument("xs_opam", metavar="XS-OPAM", nargs="?", default=None,
                        help="Path to the local clone of the xs-opam repository. "
                        "If omitted, the script will do a dry-run.")

    # In principle we don't need a default as requests can use netrc on
    # its own, however we need to know if we can find an out or now, so
    # we infer it by ourselves.
    parser.add_argument("--auth", metavar="AUTH",
                        default=get_netrc_auth(), action=AuthAction,
                        help="GitHub API authentication in the form "
                        "USER:TOKEN, where TOKEN is a Personal Access Token "
                        "(see https://github.com/settings/tokens). "
                        "If omitted, the script will try to use the "
                        "$HOME/.netrc file.")

    parser.add_argument("--ignore-xs", dest="ignore_xs", action="store_true",
                        help="Do not check if we are trying to "
                        "upgrade packages in `xs` or `xs-extra`.")

    args = parser.parse_args(argv)

    if args.auth is None and args.xs_opam is not None:
        sys.exit("Authentication is needed to be able to use the github api")

    return args


# Main body

def main(argv=None):
    """
    Entry point.
    """
    args = parse_args_or_exit(argv)

    # compute useful paths
    if args.xs_opam is not None:
        upstream_p = os.path.join(args.xs_opam, "packages", "upstream")
        upstream_extra_p = os.path.join(
            args.xs_opam, "packages", "upstream-extra")
        xs_p = os.path.join(args.xs_opam, "packages", "xs")
        xs_extra_p = os.path.join(args.xs_opam, "packages", "xs-extra")

    out = get_opam_upgrade_output()

    upgrades = [
        extract_upgrade(row) for row in out
        if "- upgrade" in row and "xenctrl" not in row
    ]

    updates = [
        extract_update(row) for row in out
        if "upstream changes" in row and "xenctrl" not in row
    ]

    new_packages = [
        extract_install(row) for row in out
        if "- install" in row and "xenctrl" not in row
    ]

    print_update_actions(upgrades, updates, new_packages)

    if not args.xs_opam:
        sys.exit(0)

    # Passed xs-opam path as argument, perform update
    upstream = set(
        d for d in os.listdir(upstream_p)
        if os.path.isdir(os.path.join(upstream_p, d)))

    upstream_extra = set(
        d for d in os.listdir(upstream_extra_p)
        if os.path.isdir(os.path.join(upstream_extra_p, d)))

    # Fail if we detect upstream updates for packages in xs or xs-extra
    if not args.ignore_xs:
        xs = set(
            d for d in os.listdir(xs_p)
            if os.path.isdir(os.path.join(xs_p, d))
        ).union(
            d for d in os.listdir(xs_extra_p)
            if os.path.isdir(os.path.join(xs_extra_p, d))
        )

        for pkg in chain(upgrades, updates):
            if pkg.current_name in xs:
                sys.exit("Packages in `xs` or `xs-extra` should not be "
                         "upgraded by opam: upgrading {}".format(
                             pkg.current_name))

    with requests.Session() as session:
        session.headers.update({"Accept": "application/vnd.github.v3+json"})

        for pkg in upgrades:
            if pkg.current_name in upstream:
                shutil.move(
                    pkg.current_path(upstream_p),
                    pkg.new_path(upstream_p))
                update_files(session, args.auth, pkg, upstream_p)

            if pkg.current_name in upstream_extra:
                shutil.move(
                    pkg.current_path(upstream_extra_p),
                    pkg.new_path(upstream_extra_p))
                update_files(session, args.auth, pkg, upstream_extra_p)

        for pkg in updates:
            if pkg in upstream:
                update_files(session, args.auth, pkg, upstream_p)

            if pkg in upstream_extra:
                update_files(session, args.auth, pkg, upstream_extra_p)

        # XXX: the new packages could be due to upstream-extra stuff.
        #      We should extend the parsing above to capture the information.
        for pkg in new_packages:
            os.makedirs(pkg.path(upstream_p))
            update_files(session, args.auth, pkg, upstream_p)

    print("Done!")


if __name__ == "__main__":
    main(sys.argv[1:])
