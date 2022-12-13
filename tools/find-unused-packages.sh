#!/usr/bin/env bash

set -euo pipefail

USED=$(opam list -t --required-by xs-toolstack --recursive --short | sort)
UPSTREAM=$(find "packages/upstream/" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I {} echo "{}" | cut -d "/" -f 3 | cut -d "." -f 1 | sort | uniq)
XS=$(find "packages/xs/" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I {} echo "{}" | cut -d "/" -f 3 | cut -d "." -f 1 | sort | uniq)
diff -u .github/unused-upstream.txt <(comm -23 <(echo "$UPSTREAM") <(echo "$USED"))
diff -u .github/unused-xs.txt <(comm -23 <(echo "$XS") <(echo "$USED"))
echo OK
