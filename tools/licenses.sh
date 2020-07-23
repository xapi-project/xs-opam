#! /bin/bash
# emit licenses for toolstack packages by querying them in the 
# current opam installation. Hence, this requires the packages in this
# repository to be installed.

set -e

opam list --required-by "xs-toolstack" --recursive --short |\
xargs opam info -f name:,license: |\
tr -d '"' |\
awk '
  /^name:/    { name = $2 }
  /^license:/ { license = $2; printf("%s: %s\n",name, license); }
'
