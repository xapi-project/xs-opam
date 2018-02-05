#!/usr/bin/env python

from __future__ import print_function
from collections import namedtuple
from itertools import chain
from subprocess import call, check_output, CalledProcessError

import os
import sys
import shutil

try:
    import requests
except Exception:
    sys.exit("The `requests` package needs to be installed. Aborting.")


########## Types ##########

Upgrade = namedtuple("Upgrade", ["cur", "new"])


########## Helpers ##########


def github_raw(package, file_name):
    package_name = package.split(".")[0]
    return "https://raw.githubusercontent.com/ocaml/opam-repository/master/packages/{}/{}/{}".format(package_name, package, file_name)


def download(url, file_path):
    r = requests.get(url)
    if r.status_code != requests.code.ok:
        print("Warning: error {} - unable to download {}".format(
            r.status_code, file_path),
            file=sys.stderr)
    with open(file_path, 'wb') as f:
        f.write(r.content)
        f.flush()


def update_files(package, new_path):
    for file_name in ["opam", "url", "descr"]:
        url = github_raw(package, file_name)
        download(url, os.path.join(new_path, file_name))


def extract_upgrade(row):
    name, cur, _, new = row.strip().split()[2:6]
    return Upgrade("{}.{}".format(name, cur), "{}.{}".format(name, new))


def extract_update(row):
    name, ver = row.strip().split()[2:4]
    return "{}.{}".format(name, ver)


def extract_install(row):
    name, ver = row.strip().split()[2:4]
    return "{}.{}".format(name, ver)



########## Parse args ##########

if any("-h" in arg for arg in sys.argv):
    print("Usage: opam-updates [-h] [XS_OPAM]")
    print("If XS_OPAM is omitted, this script will not perform any change")
    sys.exit(0)

if len(sys.argv) > 2:
    sys.exit("Only optional path to `xs-opam` expected. "
             "Too many arguments: {}".format(sys.argv))

if len(sys.argv) == 2:
    xs_opam = sys.argv[1]
    upstream_p = os.path.join(xs_opam, "packages", "upstream")
    upstream_extra_p = os.path.join(xs_opam, "packages", "upstream-extra")
else:
    xs_opam = None


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

if not xs_opam:
    if upgrades:
        print("The following updated packages are present:")
        print("\n".join(["\t- "+new for _, new in upgrades]))

    if updates:
        print("\nThe following packages changed upstream:")
        print("\n".join(["\t- "+pkg for pkg in updates]))

    if new_packages:
        print("\nThe following new packages need to be installed:")
        print("\n".join(["\t- "+pkg for pkg in new_packages]))

    sys.exit(0)



########## Passed xs-opam path as argument, perform update ##########

upstream = set(
    d for d in os.listdir(upstream_p)
    if os.path.isdir(os.path.join(upstream_p, d)))

upstream_extra = set(
    d for d in os.listdir(upstream_extra_p)
    if os.path.isdir(os.path.join(upstream_extra_p, d)))

# TODO: add xs and xs_extra and fail if any of these is modified

for cur, new in upgrades:
    if cur in upstream:
        new_path = os.path.join(upstream_p, new)
        shutil.move(
            os.path.join(upstream_p, cur),
            new_path)
        update_files(new, new_path)

    if cur in upstream_extra:
        new_path = os.path.join(upstream_extra_p, new)
        shutil.move(
            os.path.join(upstream_extra_p, cur),
            new_path)
        update_files(new, new_path)

for pkg in updates:
    if pkg in upstream:
        path = os.path.join(upstream_p, pkg)
        update_files(pkg, path)

    if pkg in upstream_extra:
        path = os.path.join(upstream_extra_p, pkg)
        update_files(pkg, path)

if new_packages:
    # TODO
    print("Auto generation of new packages not implemented")

    print("\nThe following new packages need to be installed:")
    print("\n".join(["\t- "+pkg for pkg in new_packages]))


# TODO: deal with patches and the content of files subfolders
print("Done")
