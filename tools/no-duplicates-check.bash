#!/usr/bin/env bash

set -euo pipefail

export OPAMCOLOR=NEVER

function check_no_duplicates {
  packages="$1"
  allowed_dupes_file="$2"
  for pkg in $packages; do
    the_versions=$(opam info -f all-versions "$pkg")
    versions=$(echo "$the_versions" | wc -w)
    if [ "$versions" -gt 1 ] && echo "$pkg" | grep -vqf "$allowed_dupes_file" ; then
      >&2 echo "ERROR $pkg has multiple versions: $the_versions"
      exit 1
    fi
  done
}

# Make sure no ordinary opam packages have more than a single version
# This is required because of how the rpm distributions are built: they
# try to install all versions of all ordinary packages, which fails because
# the versions of a single package are never compatible.
# several versions of the compiler might be wanted for testing:
#   ocaml, ocaml-system, ocaml-base-compiler
# several versions of the dev tools might be needed:
#   merlin, ocaml-lsp-server
packages=$(opam list --short)
dupes=".github/duplicates.txt"
check_no_duplicates "$packages" "$dupes"

echo OK
