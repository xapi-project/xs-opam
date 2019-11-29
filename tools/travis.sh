#! /bin/bash
# This script attempts to install all upstream dependencies using OCaml
# in a Docker container. This must be run from the root of the xs-opam
# repository.
# 

set -e

IMG='ocaml/opam2:debian-unstable'

docker pull $IMG
if [ "${OPAMWITHTEST}" = "true" ]; then
    # opam 2.x only tests packages listed on the cmdline, unlike opam 1.x
    INSTALL="opam list ${RECURSIVE} -s --required-by xs-toolstack | xargs opam install -t"
else
    INSTALL="opam install xs-toolstack"
fi

docker run --rm -iv $PWD:/mnt $IMG <<EOF
set -e
sudo apt-get update
opam repo remove --all default
opam repo add xs-opam --all-switches file:///mnt
opam switch ${OCAML_VERSION:-4.08}
opam depext -vv -y xs-toolstack
${INSTALL}
EOF



