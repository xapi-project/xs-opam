#!/usr/bin/env bash

set -euo pipefail

# When preparing to switch ocaml compiler versions, several versions of
# developer tools need multiple versions as each version only allows a single
# version of the compiler.
packages=$(opam list --required-by "upstream-extra-dummy" --recursive --short)
for pkg in $packages; do
  the_versions=$(opam info -f all-versions "$pkg")
  versions=$(echo "$the_versions" | wc -w)
  # severals versions of the compiler might be wanted for testing:
  #   ocaml, ocaml-system, ocaml-base-compiler, ocaml-config
  # several versions of the dev tools might be needed:
  #   merlin, ocaml-lsp-server
  if [ "$versions" -gt 1 ] && echo "$pkg" | grep -vqE '^xenctrl$' ; then
    >&2 echo "ERROR $pkg has multiple versions: $the_versions"
    exit 1
  fi
done
echo OK
