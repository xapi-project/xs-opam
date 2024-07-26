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

# makes sure no ordinary opam packages have more than a single version
# This is required because of how the rpm distributions are built: they
# try to install all versions of all ordinary packages, which fails because
# the versions of a single package are never compatible.
# several versions of the compiler might be wanted for testing:
#   ocaml, ocaml-system, ocaml-base-compiler
toolstack_packages=$(opam list --required-by "xs-toolstack" --recursive --short)
toolstack_dupes=".github/duplicates-xs-toolstack.txt"
echo checking xs-toolstack...
check_no_duplicates "$toolstack_packages" "$toolstack_dupes"

# When preparing to switch ocaml compiler versions, several versions of
# developer tools need multiple versions as each version only allows a single
# version of the compiler.
# several versions of the compiler might be wanted for testing:
#   ocaml, ocaml-system, ocaml-base-compiler, ocaml-config
# several versions of the dev tools might be needed:
#   merlin, ocaml-lsp-server
dev_packages=$(opam list --required-by "dev-tools" --recursive --short)
dev_dupes=".github/duplicates-dev-tools.txt"
echo checking dev-tools...
check_no_duplicates "$dev_packages" "$dev_dupes"

echo OK
