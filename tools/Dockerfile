FROM        ocaml/opam2:debian-9-ocaml-4.07
MAINTAINER  Christian Lindig <christian.lindig@citrix.com>

COPY --chown=opam:opam . /tmp/xs-opam

RUN sudo apt-get update
RUN opam repo remove --all default \
 && opam repo add xs-opam file:///tmp/xs-opam \
 && opam depext -y xs-toolstack \
 && opam install xs-toolstack
