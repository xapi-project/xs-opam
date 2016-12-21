
# Opam Repository for XenServer 

This repository contains an OCaml Opam repository for compiling XenServer
Toolstack components and spec files package that repository as an RPM package.

    packages/upstream     - OCaml packages
    packages/xs           - OCaml packages authored by XenServer team

The file sources.txt associates which each package its source code:

    upstream/angstrom.0.1.1                    https://github.com/inhabitedtype/angstrom/archive/0.1.1/angstrom-0.1.1.tar.gz
    upstream/astring.0.8.3                     http://erratique.ch/software/astring/releases/astring-0.8.3.tbz
    upstream/async.113.33.03                   https://ocaml.janestreet.com/ocaml-core/113.33/files/async-113.33.03.tar.gz
    upstream/async_extra.113.33.03             https://ocaml.janestreet.com/ocaml-core/113.33/files/async_extra-113.33.03.tar.gz

This file is obtained from looking at the `url` file of each package but it
needs to be edited manually to ensure that the downloaded files are unique. To
create a draft, you can run `sources.sh`. Entries that are pointing to a Git
repository need to be re-written such that hey point to a downloadable
archive.

The `Makefile` overwrites the existing `url` files with the URLs read from
`sources.txt` and downloads all packages using `opam-make`.






