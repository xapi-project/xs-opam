#! /usr/bin/env bash
# Emit a table of opam file and where to download it. This can be used
# to update Opam files to the version in a code repository

EXTRA="packages/xs-extra"
GH="https://raw.githubusercontent.com"
XAPI="xapi-project"
XSER="xenserver"

MAP="\
$EXTRA/nbd-tool.master/opam                  $GH/$XAPI/nbd/master/nbd-tool.opam
$EXTRA/rrd2csv.master/opam                   $GH/$XSER/rrd2csv/master/rrd2csv.opam
$EXTRA/xen-api-client-lwt.master/opam        $GH/$XAPI/xen-api-client/master/xen-api-client-lwt.opam
$EXTRA/xen-api-client.master/opam            $GH/$XAPI/xen-api-client/master/xen-api-client.opam
$EXTRA/xen-api-client-async.master/opam      $GH/$XAPI/xen-api-client/master/xen-api-client-async.opam
$EXTRA/xapi-database.master/opam             $GH/$XAPI/xen-api/master/xapi-database.opam
$EXTRA/xapi-client.master/opam               $GH/$XAPI/xen-api/master/xapi-client.opam
$EXTRA/xapi-consts.master/opam               $GH/$XAPI/xen-api/master/xapi-consts.opam
$EXTRA/xapi-types.master/opam                $GH/$XAPI/xen-api/master/xapi-types.opam
$EXTRA/xapi.master/opam                      $GH/$XAPI/xen-api/master/xapi.opam
$EXTRA/xapi-cli-protocol.master/opam         $GH/$XAPI/xen-api/master/xapi-cli-protocol.opam
$EXTRA/xapi-datamodel.master/opam            $GH/$XAPI/xen-api/master/xapi-datamodel.opam
$EXTRA/xe.master/opam                        $GH/$XAPI/xen-api/master/xe.opam
$EXTRA/xapi-xenopsd-xc.master/opam           $GH/$XAPI/xenopsd/master/xapi-xenopsd-xc.opam
$EXTRA/xapi-xenopsd.master/opam              $GH/$XAPI/xenopsd/master/xapi-xenopsd.opam
$EXTRA/xapi-xenopsd-simulator.master/opam    $GH/$XAPI/xenopsd/master/xapi-xenopsd-simulator.opam
$EXTRA/xapi-squeezed.master/opam             $GH/$XAPI/squeezed/master/xapi-squeezed.opam
$EXTRA/xapi-networkd.master/opam             $GH/$XAPI/xcp-networkd/master/xapi-networkd.opam
$EXTRA/forkexec.master/opam                  $GH/$XAPI/forkexecd/master/forkexec.opam
$EXTRA/xapi-forkexecd.master/opam            $GH/$XAPI/forkexecd/master/xapi-forkexecd.opam
$EXTRA/message-switch-lwt.master/opam        $GH/$XAPI/message-switch/master/message-switch-lwt.opam
$EXTRA/message-switch.master/opam            $GH/$XAPI/message-switch/master/message-switch.opam
$EXTRA/message-switch-async.master/opam      $GH/$XAPI/message-switch/master/message-switch-async.opam
$EXTRA/message-switch-cli.master/opam        $GH/$XAPI/message-switch/master/message-switch-cli.opam
$EXTRA/message-switch-core.master/opam       $GH/$XAPI/message-switch/master/message-switch-core.opam
$EXTRA/message-switch-unix.master/opam       $GH/$XAPI/message-switch/master/message-switch-unix.opam
$EXTRA/xapi-storage.master/opam              $GH/$XAPI/xapi-storage/master/xapi-storage.opam
$EXTRA/vhd-tool.master/opam                  $GH/$XAPI/vhd-tool/master/vhd-tool.opam
$EXTRA/xen-api-sdk.master/opam               $GH/$XAPI/xen-api-sdk/master/xen-api-sdk.opam
$EXTRA/xapi-plugin.master/opam               $GH/$XAPI/ocaml-xapi-plugin/master/xapi-plugin.opam
$EXTRA/xapi-storage-script.master/opam       $GH/$XAPI/xapi-storage-script/master/xapi-storage-script.opam
$EXTRA/xapi-storage-cli.master/opam          $GH/$XAPI/sm-cli/master/xapi-storage-cli.opam
$EXTRA/xapi-nbd.master/opam                  $GH/$XAPI/xapi-nbd/master/xapi-nbd.opam
$EXTRA/vncproxy.master/opam                  $GH/$XAPI/vncproxy/master/vncproxy.opam
$EXTRA/xapi-libs-transitional.master/opam    $GH/$XAPI/xen-api-libs-transitional/master/xapi-libs-transitional.opam
$EXTRA/xenctrlext.master/opam                $GH/$XAPI/xen-api-libs-transitional/master/xenctrlext.opam
$EXTRA/uuid.master/opam                      $GH/$XAPI/xen-api-libs-transitional/master/uuid.opam
$EXTRA/http-svr.master/opam                  $GH/$XAPI/xen-api-libs-transitional/master/http-svr.opam
$EXTRA/sexpr.master/opam                     $GH/$XAPI/xen-api-libs-transitional/master/sexpr.opam
$EXTRA/pciutil.master/opam                   $GH/$XAPI/xen-api-libs-transitional/master/pciutil.opam
$EXTRA/stunnel.master/opam                   $GH/$XAPI/xen-api-libs-transitional/master/stunnel.opam
$EXTRA/gzip.master/opam                      $GH/$XAPI/xen-api-libs-transitional/master/gzip.opam
$EXTRA/sha1.master/opam                      $GH/$XAPI/xen-api-libs-transitional/master/sha1.opam
$EXTRA/xml-light2.master/opam                $GH/$XAPI/xen-api-libs-transitional/master/xml-light2.opam
$EXTRA/zstd.master/opam                      $GH/$XAPI/xen-api-libs-transitional/master/zstd.opam
$EXTRA/rrdd-plugin.master/opam               $GH/$XAPI/ocaml-rrdd-plugin/master/rrdd-plugin.opam
$EXTRA/xapi-rrdd-plugin.master/opam          $GH/$XAPI/ocaml-rrdd-plugin/master/xapi-rrdd-plugin.opam
$EXTRA/xapi-rrd-transport-utils.master/opam  $GH/$XAPI/rrd-transport/master/xapi-rrd-transport-utils.opam
$EXTRA/xapi-rrd-transport.master/opam        $GH/$XAPI/rrd-transport/master/xapi-rrd-transport.opam
$EXTRA/xapi-rrdd.master/opam                 $GH/$XAPI/xcp-rrdd/master/xapi-rrdd.opam
$EXTRA/rrd-transport.master/opam             $GH/$XAPI/rrd-transport/master/rrd-transport.opam
$EXTRA/xenops.master/opam                    $GH/$XAPI/xenops/master/xenops.opam
$EXTRA/xapi-xenops.master/opam               $GH/$XAPI/xenops/master/xapi-xenops.opam
$EXTRA/xapi-xenops-utils.master/opam         $GH/$XAPI/xenops/master/xapi-xenops-utils.opam
$EXTRA/wsproxy.master/opam                   $GH/$XAPI/wsproxy/master/wsproxy.opam
$EXTRA/xapi-idl.master/opam                  $GH/$XAPI/xcp-idl/master/xapi-idl.opam
$EXTRA/xapi-tapctl.master/opam               $GH/$XAPI/tapctl/master/xapi-tapctl.opam"

echo "$MAP" | while read -r opam url; do
  curl -L "$url" > "$opam"
done
