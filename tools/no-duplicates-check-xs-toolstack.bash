#!/usr/bin/env bash

set -euo pipefail

# makes sure no ordinary opam packages have more than a single version
# the only exception is xenctrl.
# This is required because of how the rpm distributions are built: they
# try to install all versions of all ordinary packages, which fails because
# the versions of a single package are never compatible.

# when preparing to switch ocaml compiler versions, several versions of its
# packages need to be allowed as well. There are developer tools which also
# need multiple versions as each version only allows a single version of the
# compiler.
packages=$(opam list --required-by "xs-toolstack" --recursive --short)
for pkg in $packages; do
  the_versions=$(opam info -f all-versions "$pkg")
  versions=$(echo "$the_versions" | wc -w)
  # xenctrl has 2 versions: dummy and master
  # severals versions of the compiler might be wanted for testing:
  #   ocaml, ocaml-system, ocaml-base-compiler
  if [ "$versions" -gt 1 ] && echo "$pkg" | grep -vqE '^xenctrl$' ; then
    >&2 echo "ERROR $pkg has multiple versions: $the_versions"
    exit 1
  fi
done
echo OK
