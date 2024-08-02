#! /bin/bash
# Emit licenses for packaged dependencies

set -euo pipefail

# Don't allow the CI settings to break the script
OPAMCOLOR=NEVER

# opam list filters are are to eager to filter packages out, so grep is needed
# to remove unwanted packages by version. Use ; as separator and change IFS to
# make sure splits are done by newlines
SAVEDIFS=$IFS
IFS=$'\n'
for package in $(opam list --required-by xs-toolstack --recursive --short | sort | xargs opam info -f name:,license:,version: | paste -d ";" - - - | grep -ve 'version: "base"' -e 'version: "master"' -e '"ocaml"' -e '"ocaml-base-compiler"');
do
  IFS=$SAVEDIFS
  name=$(echo "$package" | cut -f 1 -d ";" | cut -f 2 -d ":" | tr -d '"' | tr -d '[:space:]')
  license_str=$(echo "$package" | cut -f 2 -d ";" | cut -f 2 -d ":")

  licenses=()
  while IFS= read -r -d '' license; do
    licenses+=("$license");
  done < <(echo "$license_str" | xargs printf '%s\0')

  sep=" AND ";
  ( IFS=; license_str="${licenses[*]/#/$sep}"; echo "$name": \""${license_str:${#sep}}"\")
done
