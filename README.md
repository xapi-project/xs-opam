# Opam Repository for XenServer

[![Build Status](https://travis-ci.org/xapi-project/xs-opam.svg?branch=opam2)](https://travis-ci.org/xapi-project/xs-opam)

This [Opam] repository contains the [OCaml] components of the XenServer
toolstack and their upstream dependencies.

## Adding the OPAM Repository

You can add this Git repository as a remote OPAM repository:

```bash
opam repo add xs-opam-quebec https://github.com/xapi-project/xs-opam.git#release/quebec/lcm
```

## Building packages

To install a package $PKG it's enough to run

```bash
opam depext $PKG
opam install $PKG
```

For development, it is often useful to clone the package sources and
only install its dependencies, leaving the job to build the package and
make changes to the developer.  This can be done as follows:

```bash
opam depext $PKG
opam install --deps-only $PKG
```

After that, you can enter the folder containing the cloned sources and
run the appropriate build command.

## Layout of This Repository

Packages are organised into namespaces:

* `upstream`: upstream packages for xs
* `upstream-extra`: upstream packages required for xs-extra
* `xs`: packages required for xs-extra
* `xs-extra`: toolstack components - latest version

## Travis

Travis builds the entire universe represented by this Opam repository.

[Opam]:   http://opam.ocaml.org
[OCaml]:  http:/ocaml.org
[Travis]: https://travis-ci.org/xapi-project/xs-opam

### Using it on your travis builds

Load the config on the install step for .travis-docker.sh at install time, then run the script for testing your package:
```
language: c
sudo: required
service: docker
install:
  - wget https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/.travis-docker.sh
  - wget https://raw.githubusercontent.com/xapi-project/xs-opam/master/tools/xs-opam-ci.env
  - source xs-opam-ci.env
script: bash -ex .travis-docker.sh
env:
  global:
    - PINS="EXAMPLE:."
    - PACKAGE="EXAMPLE"
```
