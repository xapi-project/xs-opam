#!/bin/sh
exec opam admin filter --dry-run --resolve=xs-toolstack --resolve upstream-extra-dummy --resolve depext.transition --resolve depext.1.0.5 --or --with-test
