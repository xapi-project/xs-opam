
FROM        ocaml/opam2:debian-9-ocaml-4.06
MAINTAINER  Christian Lindig <christian.lindig@citrix.com>

RUN sudo apt-get install -qq -yy \
  debianutils hwdata libdlm-dev libffi-dev libgmp-dev libnl-3-200   \
  libnl-route-3-200 libpam-dev libpci-dev libssl-dev libsystemd-dev \
  libxen-dev linux-libc-dev m4 perl pkg-config python uuid-dev \
  && sudo apt-get clean

COPY . /tmp/xs-opam

RUN opam repo remove --all default \
 && opam repo add xs-opam file:///tmp/xs-opam \
 && opam depext -y xs-toolstack \
 && opam install -j 4 xs-toolstack
