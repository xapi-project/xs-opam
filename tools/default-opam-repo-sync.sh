#! /usr/bin/env bash
# Publish packages to github.com/ocaml-opam-repository

set -xueo pipefail

# Currently opam metadata for packages in the xs directory can be exported
# as-is, while packages in xs-extra need to be transformed as they need a
# version to be able to be accepted into the repository.

XS="\
cdrom
crc
dlm
ezxenstore
fd-send-recv
nbd
netlink
xapi-backtrace
xapi-inventory
xapi-rrd
xapi-stdext-pervasives
xapi-stdext-std
xapi-stdext-threads
xapi-stdext-unix"

UPSTREAM="xenstore_transport"

XS_EXTRA="\
message-switch
vhd-tool
xapi-forkexecd
xapi-idl
xapi-libs-transitional
xapi-rrdd
xen-api-client
xenctrl"

# update the default repository to be able to synchronize the metadata
# git clone github.com:ocaml/opam-repository default-repo

echo "$XS" | while read -r pkg ; do
    xapi_dir=$(find packages/xs/ -name $pkg'\.*')
    ver_pkg=$(basename $xapi_dir)
    defo_dir="default-repo/packages/$pkg/$ver_pkg"
    if test -f "$defo_dir/opam"; then
        cp -r "$defo_dir/"* "$xapi_dir"
    else
      mkdir -p "$xapi_dir/"
      cp -rn "$xapi_dir" "$defo_dir/"
    fi
done

echo "$UPSTREAM" | while read -r pkg ; do
    xapi_dir=$(find packages/upstream/ -name $pkg'\.*')
    ver_pkg=$(basename $xapi_dir)
    defo_dir="default-repo/packages/$pkg/$ver_pkg"
    if test -f "$defo_dir/opam"; then
        cp -r "$defo_dir/"* "$xapi_dir"
    else
      mkdir -p "$xapi_dir/"
      cp -rn "$xapi_dir" "$defo_dir/"
    fi
done

