#! /bin/bash

# Script for running the tests in a container and producing a Docker image with
# the "local-build" tag that contains the installed packages.

set -ex

cat <<EOF > Dockerfile.test
FROM ocaml/opam2:${DISTRO}
COPY . /xs-opam
ENV BASE_REMOTE=${BASE_REMOTE}
ENV EXTRA_REMOTES=${EXTRA_REMOTES}
ENV COMPILE_ALL=${COMPILE_ALL}
ENV OPAM_LINT=${OPAM_LINT}
ENV CHECK_UNUSED=${CHECK_UNUSED}
ENV CHECK_TEST_DEPENDENCIES=${CHECK_TEST_DEPENDENCIES}
ENV OCAML_VERSION=${OCAML_VERSION}
ENV DISTRO=${DISTRO}
ENV SAFE_STRING=${SAFE_STRING}
WORKDIR /xs-opam
RUN bash tools/travis.sh
EOF
docker build -t local-build -f Dockerfile.test .
