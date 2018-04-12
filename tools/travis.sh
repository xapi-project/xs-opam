#! /bin/bash
#

set -ex

# override xenctrl.dummy to have a full-fledged opam repository
if [ ! "${COMPILE_ALL}" = 1 ]; then
    sudo sh tools/into_repo.sh
fi


pkg()
{
    pushd packages > /dev/null
    find  $@\
      -maxdepth 1 -mindepth 1 -type d \
      | awk -F/ '{print $NF}'
    popd > /dev/null
}

update_distro_packages()
{
    case "${DISTRO}" in
        centos*)
            sudo yum install -y epel-release
            # remove fake aspcud and install our own rpms
            wget https://github.com/xapi-project/xapi-travis-scripts/raw/master/aspcud/aspcud-1.9.0-1.el7.centos.x86_64.rpm
            wget https://github.com/xapi-project/xapi-travis-scripts/raw/master/aspcud/clasp-3.1.0-1.el7.centos.x86_64.rpm
            wget https://github.com/xapi-project/xapi-travis-scripts/raw/master/aspcud/gringo-4.4.0-1.el7.centos.x86_64.rpm
            sudo rm -rf /usr/bin/aspcud
            sudo yum install -y *.rpm
            rm *.rpm
            ;;

        debian*)
            sudo apt-get update -y
            ;;
        *)
            echo "unknown DISTRO=${DISTRO}; nothing to do"
            ;;
    esac
}

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
elif [ "${CHECK_UNUSED}" = 1 ]; then
    opam install -y --fake $XS $(pkg xs-extra-dummy)
    # Fail if there are unused packages in $UPSTREAM:
    AVAILABLE=$(pkg upstream | sed 's/\..*$//' | sort)
    INSTALLED=$(opam list | grep -v \# | cut -d' ' -f1 | sort)
    UNNEEDED=$(comm -23 <(echo "$AVAILABLE") <(echo "$INSTALLED"))
    if [ -n "$UNNEEDED" ]; then
        echo Unused packages in upstream/: $UNNEEDED
        exit 1
    fi
else
    update_distro_packages
    opam install -y depext
    opam depext  -y $XS
    opam install -y -j 4 $XS
fi

