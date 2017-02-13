
# Opam Repository for XenServer

This [Opam] repository supports building components in the XenServer
toolstack implemented in [OCaml].  You can add this Git repository as a
remote Opam repository:

  ```
  opam repo add xs-opam https://github.com/xapi-project/xs-opam.git
  ```

## Layout of This Repository

Read this to understand how to make changes

    +-- compilers                       part of Opam repo (empty)
    +-- LICENSE
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

The `packages/` directory contains Opam entries for each package. These
can be copied *untouched* from other, existing Opam repositories. The
`packages/` is basically what you get when using this repository as a
remote Opam repository. A typical entry consists of three files:

    descr
    opam
    url

[Opam]:   http://opam.ocaml.org
[OCaml]:  http:/ocaml.org

