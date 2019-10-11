#! /usr/bin/env bash
# Emit a table of opam file and where to download it. This can be used
# to update Opam files to the version in a code repository

EXTRA="packages/xs-extra"
XAPI="xapi-project"
XSER="xenserver"
LIND='lindig'

MAP="\
nbd-tool                  $XAPI/nbd
rrd2csv                   $XSER/rrd2csv
rrddump                   $XAPI/rrddump
varstored-guard           $XAPI/varstored-guard
xen-api-client-lwt        $XAPI/xen-api-client
xen-api-client            $XAPI/xen-api-client
xen-api-client-async      $XAPI/xen-api-client
xapi-database             $XAPI/xen-api
xapi-client               $XAPI/xen-api
xapi-consts               $XAPI/xen-api
xapi-types                $XAPI/xen-api
xapi                      $XAPI/xen-api
xapi-cli-protocol         $XAPI/xen-api
xapi-datamodel            $XAPI/xen-api
xe                        $XAPI/xen-api
xapi-xenopsd-xc           $XAPI/xenopsd
xapi-xenopsd              $XAPI/xenopsd
xapi-xenopsd-simulator    $XAPI/xenopsd
xapi-squeezed             $XAPI/squeezed
xapi-networkd             $XAPI/xcp-networkd
forkexec                  $XAPI/forkexecd
xapi-forkexecd            $XAPI/forkexecd
message-switch-lwt        $XAPI/message-switch
message-switch            $XAPI/message-switch
message-switch-async      $XAPI/message-switch
message-switch-cli        $XAPI/message-switch
message-switch-core       $XAPI/message-switch
message-switch-unix       $XAPI/message-switch
xapi-storage              $XAPI/xapi-storage
vhd-tool                  $XAPI/vhd-tool
xen-api-sdk               $XAPI/xen-api-sdk
xapi-plugin               $XAPI/ocaml-xapi-plugin
xapi-storage-script       $XAPI/xapi-storage-script
xapi-storage-cli          $XAPI/sm-cli
xapi-nbd                  $XAPI/xapi-nbd
vncproxy                  $XAPI/vncproxy
xapi-libs-transitional    $XAPI/xen-api-libs-transitional
xenctrlext                $XAPI/xen-api-libs-transitional
uuid                      $XAPI/xen-api-libs-transitional
http-svr                  $XAPI/xen-api-libs-transitional
sexpr                     $XAPI/xen-api-libs-transitional
pciutil                   $XAPI/xen-api-libs-transitional
stunnel                   $XAPI/xen-api-libs-transitional
gzip                      $XAPI/xen-api-libs-transitional
sha1                      $XAPI/xen-api-libs-transitional
xapi-compression          $XAPI/xen-api-libs-transitional
xml-light2                $XAPI/xen-api-libs-transitional
zstd                      $XAPI/xen-api-libs-transitional
rrdd-plugin               $XAPI/ocaml-rrdd-plugin
xapi-rrdd-plugin          $XAPI/ocaml-rrdd-plugin
xapi-rrd-transport-utils  $XAPI/rrd-transport
xapi-rrd-transport        $XAPI/rrd-transport
xapi-rrdd                 $XAPI/xcp-rrdd
rrd-transport             $XAPI/rrd-transport
xenctrl                   $LIND/xenctrl
xenops                    $XAPI/xenops
xapi-xenops               $XAPI/xenops
xapi-xenops-utils         $XAPI/xenops
xenops-cli                $XAPI/xenops-cli
wsproxy                   $XAPI/wsproxy
xapi-idl                  $XAPI/xcp-idl
xapi-tapctl               $XAPI/tapctl"

echo "$MAP" | while read -r opam repo; do
  opam_file="$EXTRA/$opam.master/opam"
  url_source="\
url {
  src: \"https://github.com/$repo/archive/master.tar.gz\"
}"

  curl -L https://raw.githubusercontent.com/"$repo"/master/"$opam".opam > "$opam_file"
  # do not add the field if it's already in the opam file
  if ! grep -Fq "url {" "$opam_file"; then
    echo "$url_source" >> "$opam_file"
  fi
done
