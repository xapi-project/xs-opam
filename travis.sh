#! /bin/bash
#

set -ex

# override xenctrl.system to have a full-fledged opam repository
sh  into_repo.sh

get()
{
  wget "https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/$1"
}

get .travis-ocaml.sh
sh  .travis-ocaml.sh


pkg()
{
    pushd packages > /dev/null
    find  $@\
      -maxdepth 1 -mindepth 1 -type d \
      | awk -F/ '{print $NF}'
    popd > /dev/null
}

if [ "${COMPILE_ALL}" = 1 ]; then
    UPSTREAM="$(pkg upstream upstream-extra)"
    XS="$(pkg xs xs-extra)"
else
    UPSTREAM="$(pkg upstream)"
    XS="$(pkg xs)"
fi

if [ "${EXTRA_REMOTES}" = 1 ]; then
    opam remote add extra "$EXTRA_REMOTES"
fi

if [ "${OPAM_LINT}" = 1 ]; then
    find packages -iname opam -print | xargs -n 1 opam lint
else
    opam install -y depext
    opam depext  -y $UPSTREAM $XS
    opam install -y -j 4 $UPSTREAM $XS
    # Workaround to mark failed uninstall as error. We only test
    # the uninstall of the xs packages but not of the upstream packages.
    opam remove  -y $XS
    opam install -y -j 4 $XS
fi

