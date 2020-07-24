# Opam Repository for Citrix Hypervisor

[![Build Status](https://travis-ci.org/xapi-project/xs-opam.svg?branch=master)](https://travis-ci.org/xapi-project/xs-opam)

This [Opam] repository contains the [OCaml] components of the Citrix
Hypervisor toolstack and their upstream dependencies. This is just
package metadata (not the actual source code) that tells [Opam] how to
download source code, compile, and install packages.

## Using this OPAM Repository for Dev Work

You can add this Git repository as a remote [Opam] repository to your
local [Opam] setup in order to install Citrix Hypervisor packages. See
below for an alternative using Docker when you don't want to use [Opam]
natively. Please be aware that this is not giving you a working Citrix
Hypervisor installation because this depends on other components. It is
most useful for development outside a build system for the complete
Citrix Hypervisor distribution.

```bash
opam repo add xs-opam https://github.com/xapi-project/xs-opam.git
```

### Installing packages

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

## Using Opam inside Docker for Dev Work

If you prefer to use [Docker] for development environments, you can
do this as well:

```bash
make
```

This builds a [Docker] image with all Citrix Hypervisor toolstack
libraries and components installed. Once built, it can be used to
compile individual packages like [xenopsd]:


```bash
$ cd src/xenopsd
$ docker run --rm -itv $PWD:/mnt xenserver/xs-opam:6.37.0
```
Inside the container you can now build [xenopsd] from sources:

```bash
opam@9a974a2229af:~/opam-repository$ cd /mnt
opam@9a974a2229af:/mnt$ ./configure
opam@9a974a2229af:/mnt$ make
```

You might run into permission problems because the user inside the
container might not be able to write files in the directory that is
mounted as a volume. Widen permissions or look into UID mapping for
docker.

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
[Docker]: https://www.docker.com/
[xenopsd]: https://github.com/xapi-project/xenopsd

### Using it on your travis builds

Load the config on the install step for .travis-docker.sh at install time, then run the script for testing your package:
```
language: c
service: docker
install:
  - wget https://raw.githubusercontent.com/ocaml/ocaml-ci-scripts/master/.travis-docker.sh
  - wget https://raw.githubusercontent.com/xapi-project/xs-opam/master/tools/xs-opam-ci.env
  - source xs-opam-ci.env
script: bash -ex .travis-docker.sh
env:
  global:
    - PINS="EXAMPLE:."
  jobs:
    - PACKAGE="EXAMPLE"
```
