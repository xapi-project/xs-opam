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

if [ "${COMPILE_ALL}" = 1 ]; then
    if [ "${OCAML_VERSION}" = "4.05.0" ]; then
        UPSTREAM="$(pkg upstream upstream-extra | grep -v 'camlp4.4.05+2' | grep -v 'ppx_tools.5.0+4.05')"
    else
        UPSTREAM="$(pkg upstream upstream-extra)"
    fi
    XS="$(pkg xs xs-extra | grep -v xenctrl.dummy)"
else
    if [ "${OCAML_VERSION}" = "4.05.0" ]; then
        UPSTREAM="$(pkg upstream | grep -v 'camlp4.4.05+2' | grep -v 'ppx_tools.5.0+4.05')"
    else
        UPSTREAM="$(pkg upstream)"
    fi
    XS="$(pkg xs)"
fi

if [ ! "${BASE_REMOTE}" = "" ]; then
    opam remote remove default
    opam remote add base "$BASE_REMOTE"
fi

if [ ! "${EXTRA_REMOTES}" = "" ]; then
    opam remote add extra "$EXTRA_REMOTES"
fi

# Set ulimit to make xapi compile
ulimit -s 16384

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

