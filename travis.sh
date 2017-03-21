#! /bin/bash
#

set -ex

export OCAML_VERSION=4.02
export OPAM_INIT=false

get()
{
  wget "https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/$1"
}

get .travis-ocaml.sh
sh  .travis-ocaml.sh

# list of packages -- excluding some that can't be installed on Travis
upstream()
{
  find \
    packages/upstream               \
    packages/upstream-extra         \
    -maxdepth 1 -mindepth 1 -type d \
  | awk -F/ '{print $NF}'           \
  | egrep -v '^(systemd)'
}

# list of packages -- excluding some that can't be installed on Travis
xs()
{
  find \
    packages/xs                     \
    -maxdepth 1 -mindepth 1 -type d \
  | awk -F/ '{print $NF}'           \
  | egrep -v '^(xenctrl|xapi-test-utils)'
}

# packages from xs-extra/ that we can compile
XS_EXTRA='
message-switch
vncproxy
wsproxy
'

# all of our packages that we can compile
XS_ALL="$(xs) $XS_EXTRA"

opam init -y local file://$PWD
opam config exec -- opam install -y -j 4 $(upstream) $XS_ALL
# Workaround to mark failed uninstall as error. We only test
# the uninstall of the XS_ALL packages but not of the upstream packages.
opam config exec -- opam remove -y $XS_ALL
opam config exec -- opam install -y -j 4 $XS_ALL


