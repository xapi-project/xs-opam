#!/bin/sh
#
# list packages that are not required by packages in this repo
#
exec opam admin filter --dry-run --resolve=xs-toolstack --resolve upstream-extra-dummy --resolve depext.transition --resolve opam-ed.0.3 --or --with-test
