
# Opam Repository for XenServer

This repository supports building components in the XenServer toolstack
implemented in [OCaml]. It can be used in two ways:

* As an external [Opam] repository.  You can add this Git repository as a
  remote Opam repository:

  ```
  opam repo add xs-opam https://github.com/xapi-project/xs-opam.git
  ```

  The code in the above repository corresponds to the branch `public` in
  this repository.

* For building and packaging this repo as an RPM.  Running

  ```
  make spec
  ```

  creates two SPEC files: `xs-opam-repo.spec` and `xs-opam-src.spec`.
  Building the corresponding RPM files (`rpmbuild -ba *.spec`) creates
  an Opam installation with all packages in this repository. When you
  inspect the generated spec files you will notice that the `build` step
  will execute a `make repo`.

## How to Add or Remove a Package

1.  Add (or remove) an Opam entry under `packages/`. This should go into
    `packages/upstream` if the code is not maintained by the Xapi
    project and `packages/xs` otherwise. Typically the entry can be
    copied from an existing Opam installation. To remove an entry,
    simply remove its directory in `packages/`.

2.  Executing `make download` will download all sources into
    `build/src`. If you added or updated a package, its source tar ball
    needs to be uploaded to Artifactory into:

      https://repo.citrite.net/ctx-local-contrib/xs-opam/

3.  Update the VERSION in the Makefile and commit all changes. Tag the
    repository with this VERSION and push the tags and the commits.

4.  Execute `make` to generate the SPEC files for xenserver-specs. The
    generated files will point to the tagged realease.

## Useful Makefile Targets

*   `make specs` generates RPM spec files
*   `make check` checks all URLs to be valid (very fast)
*   `make download` downloads all source code
*   `make repo` prepares the Opam repository (requires `download` first)
*   `make diff` compares the master and public branch for packages/*

## Branches

This repository contains the following branches:

1.  `master`: the current head of development
2.  `public`: a stripped-down version of this repository that just
    contains the Opam meta data. It is pushed to

    https://github.com/xapi-project/xs-opam.git


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
    +-- utils                           scripts
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

[Opam]:   http://opam.ocaml.org
[OCaml]:  http:/ocaml.org

