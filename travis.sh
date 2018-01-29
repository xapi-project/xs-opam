#! /bin/bash
#

set -ex

# override xenctrl.dummy to have a full-fledged opam repository
if [ ! "${COMPILE_ALL}" = 1 ]; then
    sudo sh into_repo.sh
fi

pkg()
{
    pushd packages > /dev/null
    find  $@\
      -maxdepth 1 -mindepth 1 -type d \
      | awk -F/ '{print $NF}'
    popd > /dev/null
}

if [[ "${DISTRO}" == centos* ]]; then
    sudo yum install -y epel-release
fi
if [[ "${DISTRO}" == debian* ]]; then
    sudo apt-get update -y
fi

if [ "${COMPILE_ALL}" = 1 ]; then
    UPSTREAM="$(pkg upstream upstream-extra)"
    XS="$(pkg xs xs-extra | grep -v xenctrl.dummy)"
else
    UPSTREAM="$(pkg upstream)"
    XS="$(pkg xs)"
fi

if [ ! "${BASE_REMOTE}" = "" ]; then
    opam remote remove default
    opam remote add base "$BASE_REMOTE"
fi

if [ ! "${EXTRA_REMOTES}" = "" ]; then
    opam remote add extra "$EXTRA_REMOTES"
fi

if [ "${OPAM_LINT}" = 1 ]; then
    find packages -iname opam -print | xargs -n 1 opam lint
else
    opam install -y depext
    # Do the full install/uninstall check only on the current compiler
    # For new compilers we care more to see if we can actually compile anything
    if [ "${OCAML_VERSION}" = "4.04.2" ]; then
        opam depext  -y $UPSTREAM $XS
        opam install -y -j 4 $UPSTREAM $XS
        # Workaround to mark failed uninstall as error. We only test
        # the uninstall of the xs packages but not of the upstream packages.
        opam remove  -y $XS
        opam install -y -j 4 $XS
    else
        opam depext  -y $XS
        opam install -y -j 4 $XS
    fi
fi

