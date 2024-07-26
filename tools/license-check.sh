#!/bin/bash
# Require all upstream packages in the dependency cone of xs-toolstack to be
# licensed. This excludes the unversioned packages (that have master as their
# version), as well as some of the base distribution, which also lack license
# for some weird reason.

set -euo pipefail

errors=false

# Don't allow the CI settings to break the script
OPAMCOLOR=NEVER

# xargs is the only way to split quote-enclosed elements into an array.
# e.g. "LGPL-2.0-only WITH OCaml-LGPL-linking-exception" "ISC" 
# into ("LGPL-2.0-only WITH OCaml-LGPL-linking-exception" ISC)

# opam list filters are are to eager to filter packages out, so grep is needed
# to remove unwanted packages by version. Use ; as separator and change IFS to
# make sure splits are done by newlines
SAVEDIFS=$IFS
IFS=$'\n'
for package in $(opam list --required-by xs-toolstack --recursive --short | xargs opam info -f name:,license:,version: | paste -d ";" - - - | grep -ve 'version: "base"' -e 'version: "master"');
do
  IFS=$SAVEDIFS
  name=$(echo "$package" | cut -f 1 -d ";" | cut -f 2 -d ":" | tr -d '"')
  license_str=$(echo "$package" | cut -f 2 -d ";" | cut -f 2 -d ":")

  licenses=()
  while IFS= read -r -d '' license; do
    licenses+=("$license");
    if echo "$license" | grep -qxvf .github/known-licenses.txt; then 
      echo "Unrecognised license used for $name: $license. Is it a valid a SPDX identifier?"
      errors=true
    fi
  done < <(echo "$license_str" | xargs printf '%s\0')

  if [ "${#licenses[@]}" -eq 0 ]; then 
    echo "ERROR: Package $name does not have a license"
    errors=true
  fi
done

if $errors; then
  exit 1
else
  echo OK
fi
