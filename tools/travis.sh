#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.
# 

set -e

IMG='ocaml/opam2:debian-9-ocaml-4.07'

docker pull $IMG
docker run --rm -iv $PWD:/mnt $IMG <<'EOF'
set -e

sudo apt-get update
opam repo remove --all default
opam repo add xs-opam file:///mnt
opam depext -vv -y xs-toolstack
# opam2 only runs tests for packages explicitly listed, so expand xs-toolstack
opam list --required-by=xs-toolstack --short | xargs opam install -j $(getconf _NPROCESSORS_ONLN) --with-test
EOF



