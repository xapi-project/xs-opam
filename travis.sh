#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.
# 

set -e

IMG='ocaml/opam:debian-7_ocaml-4.02.3'

docker pull $IMG
docker run --rm -iv $PWD:/mnt $IMG <<'EOF'
set -e

opam repo remove default
opam repo add xs-opam file:///mnt

cd /mnt
opam depext -iy $(cd packages/upstream; ls)
EOF



