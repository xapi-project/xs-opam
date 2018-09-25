#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.
# 

IMG='ocaml/opam:ubuntu-12.04_ocaml-4.02.3'

docker pull $IMG
docker run --rm -iv $PWD:/mnt $IMG <<'EOF'
set -x

cp -r /mnt /tmp/opam
rm -r /tmp/opam/packages/upstream/camlp4.*
opam depext -iy camlp4
opam repo remove default
opam repo add xs-opam file:///tmp/opam

# Travis is broken. We exclude some packages
P=$(cd /tmp/opam/packages/upstream; ls | egrep -v 'systemd|pci')

cd /mnt
export OPAMUSEINTERNALSOLVER=yes
opam depext -iy -j $(getconf _NPROCESSORS_ONLN) $P
EOF



