#!/usr/bin/env bash

set -euo pipefail

export LANG=C
export LC_ALL=C

export OPAMCOLOR=NEVER

DEPS_TOOLSTACK=$(opam list --required-by xs-toolstack --short | tr '\n' ,)
TEST_TOOLSTACK=$(echo "$DEPS_TOOLSTACK" | xargs opam list --test --short --required-by | tr '\n' , | xargs opam list --short --recursive --required-by)
USED_TOOLSTACK=$(echo "$DEPS_TOOLSTACK" | xargs opam list --recursive --short --required-by)
USED_DEV_TOOLS=$(opam list --required-by dev-tools --recursive --short)
USED=$(sort <(echo "$TEST_TOOLSTACK") <(echo "$USED_TOOLSTACK") <(echo "$USED_DEV_TOOLS") <(echo xs-toolstack) | uniq)
PACKAGES=$(find "packages/" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I {} echo "{}" | cut -d "/" -f 2 | sort | uniq)
diff -u .github/unused-packages.txt <(comm -23 <(echo "$PACKAGES") <(echo "$USED"))
echo OK
