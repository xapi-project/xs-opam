# override xenctrl.system to obtain an opam repository without internal xenserver dependencies
curl -L https://raw.githubusercontent.com/xapi-project/ocaml-xen-lowlevel-libs/master/opam > packages/xs/xenctrl.system/opami
echo 'archive: "https://github.com/xapi-project/ocaml-xen-lowlevel-libs/archive/master.tar.gz"' > packages/xs/xenctrl.system/url
