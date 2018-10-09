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

sudo apt-get install -qq -yy \
  debianutils hwdata libdlm-dev libffi-dev libgmp-dev libnl-3-200   \
  libnl-route-3-200 libpam-dev libpci-dev libssl-dev libsystemd-dev \
  libxen-dev linux-libc-dev m4 perl pkg-config python uuid-dev

opam repo remove --all default
opam repo add xs-opam file:///mnt
opam depext -vv -y xs-toolstack
opam install -j $(getconf _NPROCESSORS_ONLN) xs-toolstack
EOF



