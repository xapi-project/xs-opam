#! /bin/bash
#

set -ex

sh  into_repo.sh

get()
{
  wget "https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/$1"
}

get .travis-ocaml.sh
sh  .travis-ocaml.sh

# list of packages -- excluding some that can't be installed on Travis
upstream()
{
  find \
    packages/upstream               \
    packages/upstream-extra         \
    -maxdepth 1 -mindepth 1 -type d \
    | awk -F/ '{print $NF}'
}

# list of packages -- excluding some that can't be installed on Travis
xs()
{
  find \
    packages/xs                     \
    packages/xs-extra               \
    -maxdepth 1 -mindepth 1 -type d \
    | awk -F/ '{print $NF}'
}

if [ ! -z "${EXTRA_REMOTES}" ]; then
    opam remote add extra "$EXTRA_REMOTES"
fi

# opam install -y depext
# opam depext -y $(upstream) $(xs)
opam install -y -j 4 $(upstream) $(xs)
# Workaround to mark failed uninstall as error. We only test
# the uninstall of the XS_ALL packages but not of the upstream packages.
opam remove -y $(xs)
opam install -y -j 4 $(xs)

