
FROM        ocaml/opam2:debian-9-ocaml-4.06
MAINTAINER  Christian Lindig <christian.lindig@citrix.com>

RUN sudo apt-get update && sudo apt-get clean

COPY . /tmp/xs-opam

RUN opam repo remove --all default \
 && opam repo add xs-opam file:///tmp/xs-opam \
 && opam depext -y xs-toolstack \
 && opam install -j 4 xs-toolstack
