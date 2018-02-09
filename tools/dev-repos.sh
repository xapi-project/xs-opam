#! /bin/sh
# This emits the URLs of all dev repos mentioned in the opam 
# files. This relies on the opam-ed tool that can be installed using
# opam.

find . -name opam -type f | while read opam; do
  cat $opam | opam-ed 'get dev-repo' 
done | sort -u | tr -d '"'

