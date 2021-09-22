#! /usr/bin/env bash
# Emit a table of opam file and where to download it. This can be used
# to update Opam files to the version in a code repository

EXTRA="packages/xs-extra"
XAPI="xapi-project"
XSER="xenserver"

MAP="\
rrd2csv                   $XAPI/xen-api
rrddump                   $XAPI/xen-api
varstored-guard           $XAPI/varstored-guard
xen-api-client-lwt        $XAPI/xen-api
xen-api-client            $XAPI/xen-api
xen-api-client-async      $XAPI/xen-api
xapi-database             $XAPI/xen-api
xapi-client               $XAPI/xen-api
xapi-consts               $XAPI/xen-api
xapi-types                $XAPI/xen-api
xapi                      $XAPI/xen-api
xapi-cli-protocol         $XAPI/xen-api
xapi-datamodel            $XAPI/xen-api
xe                        $XAPI/xen-api
xapi-xenopsd              $XAPI/xenopsd
xapi-xenopsd-cli          $XAPI/xenopsd
xapi-xenopsd-simulator    $XAPI/xenopsd
xapi-xenopsd-xc           $XAPI/xenopsd
xapi-squeezed             $XAPI/xenopsd
xapi-networkd             $XAPI/xcp-networkd
forkexec                  $XAPI/message-switch
xapi-forkexecd            $XAPI/message-switch
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
uuid                      $XAPI/xen-api
http-svr                  $XAPI/xen-api
safe-resources            $XAPI/xen-api
sexpr                     $XAPI/xen-api
pciutil                   $XAPI/xen-api
stunnel                   $XAPI/xen-api
gzip                      $XAPI/xen-api
xapi-compression          $XAPI/xen-api
xml-light2                $XAPI/xen-api
zstd                      $XAPI/xen-api
rrdd-plugin               $XAPI/xen-api
rrdd-plugins              $XAPI/xen-api
xapi-rrdd-plugin          $XAPI/xen-api
xapi-rrd-transport-utils  $XAPI/xen-api
xapi-rrd-transport        $XAPI/xen-api
xapi-rrdd                 $XAPI/xen-api
rrd-transport             $XAPI/xen-api
xenctrl                   $XAPI/xenctrl
wsproxy                   $XAPI/wsproxy
xapi-idl                  $XAPI/message-switch
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
