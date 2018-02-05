#!/usr/bin/env python

from __future__ import print_function
from collections import namedtuple
from itertools import chain
from netrc import netrc
from subprocess import call, check_output, CalledProcessError

import os
import sys
import shutil

try:
    import requests
except Exception:
    sys.exit("The `requests` package needs to be installed. Aborting.")


########## Types ##########

class Package:
    def __init__(self, name, cur, new=None):
        self.name = name
        self.cur = cur
        self.new = new

    @property
    def github_api_url(self):
        path = "packages/{name}/{name}.{version}".format(
            name=self.name,
            version=self.new if self.new is not None else self.cur)
        return "https://api.github.com/repos/ocaml/opam-repository/contents/{}".format(path)

    @property
    def current_name(self, prefix):
        return "{}.{}".format(self.name, self.cur)

    @property
    def new_name(self, prefix):
        return "{}.{}".format(self.name, self.new)

    def current_path(self, prefix):
        os.path.join(prefix, self.current_name)

    def new_path(self, prefix):
        os.path.join(prefix, self.new_name)


########## Helpers ##########

def download(session, url, file_path):
    r = session.get(url)
    r.raise_for_status()
    with open(file_path, 'wb') as f:
        f.write(r.content)
        f.flush()


def update_files(session, auth, package, prefix):
    base_url = package.github_api_url

    r = session.get(base_url, auth=auth)
    r.raise_for_status()
    entries = r.json()

    for entry in entries:
        if entry["type"] == "dir":
            continue
        new_path = os.path.join(package.new_path(prefix), entry["name"])
        download(session, entry["download_url"], new_path)

    if any(entry["type"] == "dir"
           and entry["name"] == "files"
           for entry in entries):
        r = session.get(os.path.join(base_url, "files"), auth=auth)
        r.raise_for_status()
        entries = r.json()
        prefix = os.path.join(package.new_path(prefix), "files")
        os.mkdir(prefix)

        for entry in entries:
            if entry["type"] == "dir":
                continue
            new_path = os.path.join(package.new_path(prefix), entry["name"])
            download(session, entry["download_url"], new_path)


def extract_upgrade(row):
    name, cur, _, new = row.strip().split()[2:6]
    return Package(name, cur, new)


def extract_update(row):
    name, ver = row.strip().split()[2:4]
    return Package(name, ver)


def extract_install(row):
    name, ver = row.strip().split()[2:4]
    return Package(name, ver)


########## Parse args ##########
# TODO: rewrite with argparse

if any("-h" in arg for arg in sys.argv):
    print("Usage: opam-updates [-h] [XS_OPAM]")
    print("If XS_OPAM is omitted, this script will not perform any change")
    sys.exit(0)

if len(sys.argv) > 3:
    sys.exit("Only optional path to `xs-opam` expected. "
             "Too many arguments: {}".format(sys.argv))

if len(sys.argv) == 2:
    xs_opam = sys.argv[1]
    upstream_p = os.path.join(xs_opam, "packages", "upstream")
    upstream_extra_p = os.path.join(xs_opam, "packages", "upstream-extra")
else:
    xs_opam = None

# TODO: parse auth
try:
    login, _, password = netrc().authenticators("github.com")
    auth = (login, password)
except ValueError:
    if xs_opam is not None:
        sys.exit("Authentication is needed to be able to use the github api")

########## Main script ###########

call("sudo yum install jq -y".split(' '))
call("opam remote add upstream https://opam.ocaml.org".split(' '))

try:
    opam_out = check_output("opam upgrade --dry-run -y".split(' '))
except CalledProcessError as err:
    sys.exit(err.output)

out = opam_out.split('\n')

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

if upgrades:
    print("The following updated packages are present:")
    print("\n".join(["\t- "+new for _, new in upgrades]))

if updates:
    print("\nThe following packages changed upstream:")
    print("\n".join(["\t- "+pkg for pkg in updates]))

if new_packages:
    print("\nThe following new packages need to be installed:")
    print("\n".join(["\t- "+pkg for pkg in new_packages]))

if not xs_opam:
    sys.exit(0)


########## Passed xs-opam path as argument, perform update ##########

upstream = set(
    d for d in os.listdir(upstream_p)
    if os.path.isdir(os.path.join(upstream_p, d)))

upstream_extra = set(
    d for d in os.listdir(upstream_extra_p)
    if os.path.isdir(os.path.join(upstream_extra_p, d)))

# TODO: add xs and xs_extra and fail if any of these is modified

with requests.Session() as session:
    session.headers.update({"Accept": "application/vnd.github.v3+json"})

    for pkg in upgrades:
        if pkg.current_name in upstream:
            shutil.move(
                pkg.current_path(upstream_p),
                pkg.new_path(upstream_p))
            update_files(session, auth, pkg, upstream_p)

        if pkg.current_name in upstream_extra:
            shutil.move(
                pkg.current_path(upstream_extra_p),
                pkg.new_path(upstream_extra_p))
            update_files(session, auth, pkg, upstream_extra_p)

    for pkg in updates:
        if pkg in upstream:
            update_files(session, auth, pkg, upstream_p)

        if pkg in upstream_extra:
            update_files(session, auth, pkg, upstream_extra_p)

    if new_packages:
        # TODO
        print("Auto generation of new packages not implemented")

        print("\nThe following new packages need to be installed:")
        print("\n".join(["\t- "+pkg for pkg in new_packages]))


# TODO: deal with patches and the content of files subfolders
print("Done")
