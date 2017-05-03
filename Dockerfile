FROM ocaml/opam:ubuntu-16.04_ocaml-4.02.3
MAINTAINER Marcello Seri <marcello.seri@citrix.com>

COPY . /xs-opam
RUN opam repo add xs-opam /xs-opam

RUN sudo apt-get update \
    && sudo apt-get install -y vim emacs

RUN opam update \
    && opam upgrade -y \
    && opam install merlin ocp-browser ocp-indent ocp-index depext user-setup utop \
    && opam user-setup install

