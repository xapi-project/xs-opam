#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.

set -e

OCAML_VERSION=${OCAML_VERSION:-4.08}

IMG="ocurrent/opam:debian-10-ocaml-$OCAML_VERSION"

docker pull $IMG

docker run --rm -iv "$PWD:/mnt" $IMG <<EOF
set -e
sudo apt-get update
opam repo remove --all default
opam repo add xs-opam --all-switches file:///mnt
opam switch $OCAML_VERSION
opam depext -vv -y xs-toolstack
# opam 2 only tests packages listed on the cmdline
OPAMERRLOGLEN=10000 opam list -s --required-by xs-toolstack | xargs opam install -t
EOF
