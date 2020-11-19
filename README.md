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
compile individual packages like [xenopsd]. The image can be found with
`docker image`:


```bash
$ cd src/xenopsd
$ docker image ls xenserver/xs-opam
REPOSITORY         TAG     IMAGE         ID  CREATED  SIZE
xenserver/xs-opam  6.37.0  1744d037eaec  2   days     ago   4.51GB
xenserver/xs-opam  6.35.0  131c4fc20e0c  8   days     ago   6.46GB
xenserver/xs-opam  6.31.0  b49d1b5311f4  3   months   ago   6.36GB
..
$ docker run --rm -itv $PWD:/mnt xenserver/xs-opam:6.37.
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

## Continuous Integration

Github Actions builds the entire universe represented by this Opam repository.

[Opam]:    http://opam.ocaml.org
[OCaml]:   http:/ocaml.org
[Docker]:  https://www.docker.com/

### Using xs-opam on github actions builds

To use the repository in github actions 3 steps are needed to set up the opam environment:
- One to download the .env file
- One to load it into the environment
- One to initialize the opam environment

Here's an example template for the standard `.github/workflows/main.yml`, package should be change to include the opam packages available in the repository and the build and test steps adapted to the repository.

```yaml
name: Build and test

on:
  push:
  pull_request:

jobs:
  ocaml-test:
    name: Ocaml tests
    runs-on: ubuntu-20.04
    env:
      package: "EXAMPLE-BINARY EXAMPLE-LIBRARY"

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Pull configuration from xs-opam
        run: |
          curl --fail --silent https://raw.githubusercontent.com/xapi-project/xs-opam/master/tools/xs-opam-ci.env | cut -f2 -d " " > .env

      - name: Load environment file
        id: dotenv
        uses: falti/dotenv-action@v0.2.4

      - name: Use ocaml
        uses: avsm/setup-ocaml@v1
        with:
          ocaml-version: ${{ steps.dotenv.outputs.ocaml_version_full }}
          opam-repository: ${{ steps.dotenv.outputs.repository }}

      - name: Install dependencies
        run: |
          opam pin add . --no-action
          opam depext -u ${{ env.package }}
          opam install ${{ env.package }} --deps-only --with-test -v

      - name: Build
        run: |
          opam exec -- ./configure
          opam exec -- make

      - name: Run tests
        run: opam exec -- make test
```
