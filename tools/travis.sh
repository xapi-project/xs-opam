#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.
# 

set -e

IMG='ocaml/opam2:debian-unstable'

docker pull $IMG
docker run --rm -iv $PWD:/mnt $IMG <<'EOF'
set -e

sudo apt-get update
opam repo remove --all default
opam repo add xs-opam --all-switches file:///mnt
opam switch 4.07
opam depext -vv -y xs-toolstack
opam install -j $(getconf _NPROCESSORS_ONLN) xs-toolstack
EOF



