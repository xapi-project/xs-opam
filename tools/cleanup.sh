#!/bin/sh
#
# list packages that are not required by packages in this repo
#
exec opam admin filter --dry-run --resolve=xs-toolstack --resolve upstream-extra-dummy --resolve depext.transition --resolve opam-ed.0.3 --resolve ocaml-base-compiler.4.08.1 --resolve ppx_tools.6.0+4.08.0 --resolve ocaml-system.4.08.1 --or --with-test
