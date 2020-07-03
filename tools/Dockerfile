FROM ocaml/opam2:debian-10-ocaml-4.08
MAINTAINER  Christian Lindig <christian.lindig@citrix.com>

COPY . /tmp/xs-opam

RUN sudo apt-get update
RUN opam repo remove --all default \
 && opam repo add xs-opam --all-switches file:///tmp/xs-opam \
 && opam switch 4.08 \
 && opam depext -y xs-toolstack \
 && opam install xs-toolstack
