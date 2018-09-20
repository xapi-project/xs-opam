#! /bin/bash
# Emit a table of opam file and where to download it. This can be used
# to update Opam files to the version in a code repository 

XS="packages/xs-extra"
GH="https://raw.githubusercontent.com/xapi-project"

MAP="
$XS/nbd-tool.master/opam                  $GH/nbd/master/nbd-tool.opam
$XS/xen-api-client-lwt.master/opam        $GH/xen-api-client/master/xen-api-client-lwt.opam
$XS/xen-api-client.master/opam            $GH/xen-api-client/master/xen-api-client.opam
$XS/xen-api-client-async.master/opam      $GH/xen-api-client/master/xen-api-client-async.opam
$XS/xapi-database.master/opam             $GH/xen-api/master/xapi-database.opam
$XS/xapi-client.master/opam               $GH/xen-api/master/xapi-client.opam
$XS/xapi-consts.master/opam               $GH/xen-api/master/xapi-consts.opam
$XS/xapi-types.master/opam                $GH/xen-api/master/xapi-types.opam
$XS/xapi.master/opam                      $GH/xen-api/master/xapi.opam
$XS/xapi-cli-protocol.master/opam         $GH/xen-api/master/xapi-cli-protocol.opam
$XS/xapi-datamodel.master/opam            $GH/xen-api/master/xapi-datamodel.opam
$XS/xe.master/opam                        $GH/xen-api/master/xe.opam
$XS/xapi-xenopsd-xc.master/opam           $GH/xenopsd/master/xapi-xenopsd-xc.opam
$XS/xapi-xenopsd.master/opam              $GH/xenopsd/master/xapi-xenopsd.opam
$XS/xapi-xenopsd-simulator.master/opam    $GH/xenopsd/master/xapi-xenopsd-simulator.opam
$XS/forkexec.master/opam                  $GH/forkexecd/master/forkexec.opam
$XS/xapi-forkexecd.master/opam            $GH/forkexecd/master/xapi-forkexecd.opam
$XS/message-switch-lwt.master/opam        $GH/message-switch/master/message-switch-lwt.opam
$XS/message-switch.master/opam            $GH/message-switch/master/message-switch.opam
$XS/message-switch-async.master/opam      $GH/message-switch/master/message-switch-async.opam
$XS/message-switch-cli.master/opam        $GH/message-switch/master/message-switch-cli.opam
$XS/message-switch-core.master/opam       $GH/message-switch/master/message-switch-core.opam
$XS/message-switch-unix.master/opam       $GH/message-switch/master/message-switch-unix.opam
$XS/xapi-netdev.master/opam               $GH/netdev/master/xapi-netdev.opam
$XS/xapi-storage.master/opam              $GH/xapi-storage/master/xapi-storage.opam
$XS/vhd-tool.master/opam                  $GH/vhd-tool/master/vhd-tool.opam
$XS/xen-api-sdk.master/opam               $GH/xen-api-sdk/master/xen-api-sdk.opam
$XS/xapi-plugin.master/opam               $GH/ocaml-xapi-plugin/master/xapi-plugin.opam
$XS/xapi-storage-script.master/opam       $GH/xapi-storage-script/master/xapi-storage-script.opam
$XS/xapi-storage-cli.master/opam          $GH/sm-cli/master/xapi-storage-cli.opam
$XS/xapi-nbd.master/opam                  $GH/xapi-nbd/master/xapi-nbd.opam
$XS/vncproxy.master/opam                  $GH/vncproxy/master/vncproxy.opam
$XS/xapi-libs-transitional.master/opam    $GH/xen-api-libs-transitional/master/xapi-libs-transitional.opam
$XS/xenctrlext.master/opam                $GH/xen-api-libs-transitional/master/xenctrlext.opam
$XS/uuid.master/opam                      $GH/xen-api-libs-transitional/master/uuid.opam
$XS/http-svr.master/opam                  $GH/xen-api-libs-transitional/master/http-svr.opam
$XS/sexpr.master/opam                     $GH/xen-api-libs-transitional/master/sexpr.opam
$XS/pciutil.master/opam                   $GH/xen-api-libs-transitional/master/pciutil.opam
$XS/stunnel.master/opam                   $GH/xen-api-libs-transitional/master/stunnel.opam
$XS/gzip.master/opam                      $GH/xen-api-libs-transitional/master/gzip.opam
$XS/sha1.master/opam                      $GH/xen-api-libs-transitional/master/sha1.opam
$XS/xml-light2.master/opam                $GH/xen-api-libs-transitional/master/xml-light2.opam
$XS/rrdd-plugin.master/opam               $GH/ocaml-rrdd-plugin/master/rrdd-plugin.opam
$XS/xapi-rrdd-plugin.master/opam          $GH/ocaml-rrdd-plugin/master/xapi-rrdd-plugin.opam
$XS/xapi-rrd-transport-utils.master/opam  $GH/rrd-transport/master/xapi-rrd-transport-utils.opam
$XS/xapi-rrd-transport.master/opam        $GH/rrd-transport/master/xapi-rrd-transport.opam
$XS/rrd-transport.master/opam             $GH/rrd-transport/master/rrd-transport.opam
$XS/xenops.master/opam                    $GH/xenops/master/xenops.opam
$XS/xapi-xenops.master/opam               $GH/xenops/master/xapi-xenops.opam
$XS/xapi-xenops-utils.master/opam         $GH/xenops/master/xapi-xenops-utils.opam
$XS/wsproxy.master/opam                   $GH/wsproxy/master/wsproxy.opam
$XS/xapi-idl.master/opam                  $GH/xcp-idl/master/xapi-idl.opam
$XS/xcp.master/opam                       $GH/xcp-idl/master/xcp.opam
$XS/xapi-tapctl.master/opam               $GH/tapctl/master/xapi-tapctl.opam
"

echo "$MAP" | while read opam url; do
  curl -L $url > $opam
done
