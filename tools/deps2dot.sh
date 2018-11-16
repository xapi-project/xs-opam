#! /bin/sh

set -e

P=$(opam list --columns=name | grep -v '#')
echo "digraph deps {" 
for p in $P; do
  x=$(opam list --required-by="$p" --columns=name | grep -v '#')
  for i in $x; do
    echo "\"$p\" -> \"$i\";"
  done
  echo
done
echo "}"

