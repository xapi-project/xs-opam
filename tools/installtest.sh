#!/bin/bash
#
# list packages that are not required by packages in this repo

# with-test only looks at test dependencies of the packages listed on the
# cmdline, not everything recursively
# so find out recursive deps of xs-toolstack: we want to run tests for all of
# those (but we don't necessarily need to run the tests of packages pulled in
# only for testing - that is sometimes not all solvable with same versions)
set -euo pipefail

# there are conflicts with some of these test dependencies or bring in too many other packages
# next time we upgrade them we should aim to make them testable
# ocaml-system should always be excluded because the system compiler may be quite different from what we use here
NOTEST=ocaml-system\|ppx_cstruct\|ipaddr-sexp
ALLDEPS=$(opam admin filter --dry-run --resolve=xs-toolstack | sed -n 2p | tr ' ' '\n' |grep -vE ${NOTEST} | tr '\n' ' ')
opam install --no-depexts --with-test ${ALLDEPS} -y
