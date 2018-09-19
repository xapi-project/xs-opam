#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.
# 

set -e

IMG='ocaml/opam2:debian-9-ocaml-4.06'

docker pull $IMG
docker run --rm -iv $PWD:/mnt $IMG <<'EOF'
set -e

opam repo remove --all default
opam repo add xs-opam file:///mnt

cd /mnt
opam depext -iy -j $(getconf _NPROCESSORS_ONLN) xs-toolstack
EOF



