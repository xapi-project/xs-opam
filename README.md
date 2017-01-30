
# Opam Repository for XenServer

This repository supports building components in the XenServer toolstack
implemented in OCaml. It can be used in two ways:

## External Opam Repositoty

You can add this Git repository as a remote Opam repository:

    opam repo add xs-opam https://github.com/lindig/xs-opam.git

## Building and Packaging as RPM

Running

    make spec

creates two SPEC files:

    xs-opam-repo.spec
    xs-opam-src.spec

Building the corresponding RPM files (`rpmbuild -ba *.spec`) creates an
Opam installation with all packages in this repository. When you inspect
the generated spec files you will notice that the `build` step will
execute a `make repo`.

## Layout of This Repository

Read this to understand how to make changes

    +-- compilers                       part of Opam repo (empty)
    +-- LICENSE
    +-- Makefile
    +-- packages                        part of Opam repo
    |   +-- upstream                    all upstream packages
    |   |   +-- angstrom.0.1.1
    |   |   |   +-- descr
    |   |   |   +-- findlib
    |   |   |   +-- opam
    |   |   |   \-- url
    |   |   \-- zed.1.4
    |   |       +-- descr
    |   |       +-- findlib
    |   |       +-- opam
    |   |       \-- url
    |   \-- xs                          all XenServer packages
    |       +-- message-switch.jonludlam#ppx
    |       |   +-- descr
    |       |   +-- opam
    |       |   \-- url
    |       \-- xenstore_transport.0.9.4
    |           +-- descr
    |           +-- findlib
    |           +-- opam
    |           \-- url
    +-- README.md
    +-- sources.txt                     download locations
    +-- utils                           various scripts, not called
    +-- xs-opam-repo.in                 spec file template
    +-- xs-opam-repo.spec
    +-- xs-opam-src.in                  spec file template
    \-- xs-opam-src.spec


The `packages/` directory contains Opam entries for each package. These
can be copied *untouched* from other, existing Opam repositories. The
`packages/` is basically what you get when using this repository as a
remote Opam repository. A typical entry consists of three files:

    descr
    opam
    url

In addition, `sources.txt` contains one line per package, like this:

  upstream/bos.0.1.4  http://erratique.ch/software/bos/releases/bos-0.1.4.tbz

This is used to download the source code packages when constructing the
RPM and when doing `make download`. During the construction of the
`xs-opam-src` RPM, entries in this file are used to rewrite the `url`
file. This step is performed by the `make repo` step -- see the
`Makefile`.

The download location is most of the time a simplified version of the
content of the `url` file and this is where you would find it. However,
some `url` files point to Git repositories or create file names that are
not unique. In that case the entry of `sources.txt` will differ from the
`url` entry.

## How to Add or Remove a Package

1.  Add an Opam entry under `packages/`. This should go into
    `packages/upstream` if the code is not maintained by the Xapi
    project and `packages/xs` otherwise. Typically the entry can be
    copied from an existing Opam installation. To remove an entry,
    simply remove its directory in `packages/`.

2.  Execute `make update`. This will update all download links in
    `sources.txt` and check them. A download link is
    extracted from a package's `url` file and usually used verbatim.
    However, in the case of links to GitHub, some are rewritten to make
    sure the resulting file is sensibly named. If the link derived from
    this step does not make sense, modify method `Opam::url` in
    `utils/sources.rb`.  You can optionally execute `make download` to
    download all source code.

3.  Execute `make spec` to generate the SPEC files that you might want
    to use.

## How it Works

Opam was never designed to be packaged and installed as an RPM so expect
some rough edges. But it avoids packaging every single OCaml package as
an RPM. It works roughly like this:

1. Building `xs-opam-src` creates an Opam repository with all packages
   downloaded as source code. This Opam repository gets installed when
   `xs-opam-src` is installed but it does not yet build the packages
   inside that Opam repository.

2. Building `xs-opam-repo` depends on `xs-opam-src`. The RPM build step
   does an `opam install` for all packages which leads them to be
   compiled and installed. The installed libraries are then packaged in
   the RPM.

Building the RPM files from `xs-opam-*.spec` requires putting all the
sources into `SOURCES/` of an `rpmbuild/` hierarchy. This repository has
no immediate support for this but `make download` will download the
source code for all packages. In addition, this repository needs to be
available as `xs-opam-master.tar.gz` (as listed in `xs-opam-src.spec`).


