#!/usr/bin/env bash

set -euo pipefail

# makes sure no ordinary opam packages have more than a single version
# the only exceptions are ocaml and xenctrl.
# This is required because of how the rpm distributions are built: they
# try to install all versions of all ordinary packages, which fails because
# the versions of a single package are never compatible.

packages=$(opam list --required-by "xs-toolstack" --recursive --short)
for pkg in $packages; do
  the_versions=$(opam info -f all-versions "$pkg")
  versions=$(echo "$the_versions" | wc -w)
  # the compiler is allowed to have more than one version because it's a
  # separate rpm. xenctrl has 2 versions: dummy and master
  if [ "$versions" -gt 1 ] && echo "$pkg" | grep -vqE '^ocaml$|^ocaml-base-compiler$|^ocaml-system$|^ocaml-config$|^xenctrl$' ; then
    >&2 echo "ERROR $pkg has multiple versions: $the_versions"
    exit 1
  fi
done
echo OK
