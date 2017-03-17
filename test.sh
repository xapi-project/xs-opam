#! /bin/bash
#
# This script can be executed in a CentOS environment to test the
# Opam repository by building components from the xs-extra hierarchy.
#
# The packages that are required make it obvious that this
# Opam repository is not fully general and portable. The most
# problematic package is xs/xenctrl.
#
# This script could provides hints how to implement a more complete
# Travis configuration that is based on a CentOS Docker container.
#

PKG='
rsync
m4
xen-libs-devel
openssl-devel
ocaml
opam
ocaml-camlp4-devel
ocaml-ocamldoc
pam-devel
xen-devel
libffi-devel
zlib-devel
systemd-devel
pciutils-devel
xen-dom0-libs-devel
systemd
xen-ocaml-devel
'

sudo yum install -y $PKG
opam init -y local file://$PWD
eval $(opam config env)
opam update
opam install -y xapi-xenopsd xapi


