#!/bin/sh
exec opam admin filter --dry-run --resolve=xs-toolstack --resolve upstream-extra-dummy --resolve depext.transition --resolve opam-ed.0.1 --or --with-test
