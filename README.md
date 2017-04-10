
[![Build Status](https://travis-ci.org/xapi-project/xs-opam.svg?branch=master)](https://travis-ci.org/xapi-project/xs-opam)

# Opam Repository for XenServer

This [Opam] repository supports building components in the XenServer
toolstack implemented in [OCaml].

## Adding the OPAM Repository

This repository has been tested with OCaml 4.02.3. To initialize an OPAM
configuration with this compiler version, run:

  ```
  opam init --comp=4.02.3
  eval `opam config env`
  ```

You can add this Git repository as a remote OPAM repository:

  ```
  opam repo add xs-opam https://github.com/xapi-project/xs-opam.git
  ```

Not all packages in `packages/xs-extra` can be built. To have a
full-fledged opam repository you can proceed as follows:

  ```
  git clone https://github.com/xapi-project/xs-opam.git
  cd xs-opam
  sh into_repo.sh
  opam repo add xs-opam .
  ```

## Layout of This Repository

Packages are organised into namespaces:

* `upstream`: packages that we don't control with fixed versions.
* `upstream-extra`: packages that we don't control with fixed versions
  and don't require as a build dependency.
* `xs`: packages that we control, with fixed versions.
* `xs-extra`: packages that we control, following their respective
  master branch.

The namespaces are treated differently as part of the build process of
XenServer components but this should not concern an Opam user - packages
in all namespaces together form the repository and there is no
difference between them.

```
./packages/upstream
./packages/upstream-extra
./packages/xs
./packages/xs-extra
```

The `packages/` hierarchy contains [Opam] entries for each package. These
can be copied *untouched* from other, existing [Opam] repositories. The
`packages/` is basically what you get when using this repository as a
remote Opam repository. A typical entry consists of three files:

* `descr` - textual desciption
* `opam` - dependencies and build instructions
* `url` - link to source code

Note how versions are designated:

    packages/xs/cdrom.0.9.2
    packages/xs/crc.1.0.0
    packages/xs-extra/libvirt.djs
    packages/xs-extra/message-switch.master
    packages/xs-extra/rrddump.master
    packages/xs-extra/vncproxy.master
    packages/xs-extra/wsproxy.master
    packages/xs/fd-send-recv.1.0.2
    packages/xs/nbd.2.1.2
    packages/xs/netlink.0.2.1

# Travis

A subset of packages in this repository are built on the [Travis] CI
service. These are library packages that part of XenServer. The full set
of packages is built as well but failure to build it doesn't count as a
build failure so far. See `.travis.yml` and `travis.sh` for details.

[Opam]:   http://opam.ocaml.org
[OCaml]:  http:/ocaml.org
[Travis]: https://travis-ci.org/xapi-project/xs-opam
