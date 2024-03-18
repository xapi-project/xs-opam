#! /bin/bash
# emit licenses for toolstack packages, needs to be run at the root of the
# project 

set -e

for file in packages/{upstream,xs}/*/opam;
do
  name=$(basename ${file%%.*})
  license=$(grep 'license: ' $file | awk -F ': ' '{print $2}')
  echo $name: $license
done
