#!/bin/bash
#
# list packages that are not required by packages in this repo

# with-test only looks at test dependencies of the packages listed on the
# cmdline, not everything recursively
# so find out recursive deps of xs-toolstack: we want to run tests for all of
# those (but we don't necessarily need to run the tests of packages pulled in
# only for testing - that is sometimes not all solvable with same versions)
set -euo pipefail
. "$(dirname "$0")/xs-opam-ci.env"
opam admin check --ignore-test-doc
# there is a conflict in ppxlib and sexplib0 version in with-test, ignore its tests for now
RESOLVE=$(opam admin filter --verbose --dry-run --resolve=xs-toolstack | sed -n 2p | grep -v ppxlib)
RESOLVE+=" upstream-extra-dummy opam-depext opam-ed.0.3"
RESOLVE+=" ocaml-base-compiler.${OCAML_VERSION_FULL} ocaml-system.${OCAML_VERSION_FULL}"
exec opam admin filter --dry-run "--resolve=$(echo ${RESOLVE} | tr ' ' ',')" --or --with-test
