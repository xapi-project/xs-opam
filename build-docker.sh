# Script for running the tests in a container and producing a Docker image with
# the "local-build" tag that contains the installed packages.

set -ex

echo FROM ocaml/opam:${DISTRO}_ocaml-${OCAML_VERSION} > Dockerfile.test
echo COPY . /xs-opam >> Dockerfile.test
echo "ENV BASE_REMOTE=${BASE_REMOTE}"     >> Dockerfile.test
echo "ENV EXTRA_REMOTES=${EXTRA_REMOTES}" >> Dockerfile.test
echo "ENV COMPILE_ALL=${COMPILE_ALL}"     >> Dockerfile.test
echo "ENV OPAM_LINT=${OPAM_LINT}"         >> Dockerfile.test
echo "ENV OCAML_VERSION=${OCAML_VERSION}" >> Dockerfile.test
echo WORKDIR /xs-opam                     >> Dockerfile.test
echo RUN bash travis.sh                   >> Dockerfile.test
docker build -t local-build -f Dockerfile.test .
