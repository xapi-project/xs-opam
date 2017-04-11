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

UPSTREAM="$(pkg upstream)"
XS="$(pkg xs)"

opam install -y depext
opam depext  -y $UPSTREAM $XS
opam install -y -j 4 $UPSTREAM $XS

