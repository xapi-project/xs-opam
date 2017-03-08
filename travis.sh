#! /bin/bash
#

set -ex

OCAML_VERSION=4.02.3

get()
{
  wget "https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/$1"
}

get .travis-ocaml.sh
sh  .travis-ocaml.sh

# list of packages -- excluding some that can't be installed on Travis
pkg()
{
	find packages/upstream -maxdepth 1 -mindepth 1 -type d \
	| awk -F/ '{print $NF}' \
	| egrep -v '^(systemd)'
}

# packages from xs/ that we can compile
XS='
cdrom
crc
fd-send-recv
message-switch
nbd
netlink
opasswd
rpc
shared-block-ring
xapi-backtrace
xapi-idl
xapi-inventory
xapi-rrd
xapi-stdext
xen-api-client
xenstore
xenstore_transport
'

opam config exec -- opam repository add local file://$PWD
opam config exec -- opam repository remove default
opam config exec -- opam repository list
opam config exec -- opam install -y -j 2 $(pkg) $XS
opam config exec -- opam remove -y $XS


