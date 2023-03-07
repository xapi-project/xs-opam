#! /bin/bash
# Require all upstream packages to be licensed

set -euo pipefail

errors=false

for file in packages/{upstream,xs}/*/opam;
do
  name=$(basename ${file%%.*})
  if ! license=$(grep 'license: ' $file); then 
    echo "ERROR: Package $name does not have a license"
    errors=true
  fi
  license=$(grep -Po 'license: \K.*' $file| tr -d '"')
  if echo $license | grep -qxvf .github/known-licenses.txt; then 
    echo "Unrecognised license used for $name: $license. Is it a valid a SPDX identifier?"
    errors=true
  fi
done

if $errors; then
  exit 1
else
  echo OK
fi
