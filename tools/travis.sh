#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.

set -e

OCAML_VERSION_FULL=${OCAML_VERSION_FULL:-4.08.1}
OCAML_VERSION=${OCAML_VERSION_FULL%.*}

IMG="ocaml/opam2:debian-10-ocaml-$OCAML_VERSION"

docker pull $IMG

docker run --rm -iv "$PWD:/mnt" $IMG <<EOF
set -e
sudo apt-get update
opam repo remove --all default
opam repo add xs-opam --all-switches file:///mnt
opam switch $OCAML_VERSION && opam upgrade ocaml=$OCAML_VERSION_FULL --unlock-base -y
opam depext -vv -y xs-toolstack
# opam 2 only tests packages listed on the cmdline
OPAMERRLOGLEN=10000 opam list -s --required-by xs-toolstack | xargs opam install -t
EOF
