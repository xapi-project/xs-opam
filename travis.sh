#! /bin/bash
#

set -e

OCAML_VERSION=4.02.3

get()
{
  wget "https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/$1"
}

get .travis-ocaml.sh
sh  .travis-ocaml.sh

PKG="$PKG $(ls -1 packages/upstream | grep -v systemd.stable)"
# PKG="$PKG $(ls -1 packages/xs)"

opam config exec -- opam repository add local file://$PWD
opam config exec -- opam repository remove default
opam config exec -- opam repository list
opam config exec -- opam install -y -j 2 $PKG



