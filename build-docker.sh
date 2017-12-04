# Script for running the tests in a container and producing a Docker image with
# the "local-build" tag that contains the installed packages.

set -ex

cat <<EOF > Dockerfile.test
FROM ocaml/opam:${DISTRO}_ocaml-${OCAML_VERSION}
COPY . /xs-opam
"ENV BASE_REMOTE=${BASE_REMOTE}"
"ENV EXTRA_REMOTES=${EXTRA_REMOTES}"
"ENV COMPILE_ALL=${COMPILE_ALL}"
"ENV OPAM_LINT=${OPAM_LINT}"
"ENV OCAML_VERSION=${OCAML_VERSION}"
WORKDIR /xs-opam
RUN bash travis.sh
EOF
docker build -t local-build -f Dockerfile.test .
