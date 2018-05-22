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

replace_centos_aspcud()
{
    case "${DISTRO}" in
        centos*)
            # remove fake aspcud and install our own rpms
            mkdir /tmp/aspcud
            wget https://github.com/xapi-project/xapi-travis-scripts/raw/master/aspcud/aspcud-1.9.0-1.el7.centos.x86_64.rpm -P /tmp/aspcud
            wget https://github.com/xapi-project/xapi-travis-scripts/raw/master/aspcud/clasp-3.1.0-1.el7.centos.x86_64.rpm -P /tmp/aspcud
            wget https://github.com/xapi-project/xapi-travis-scripts/raw/master/aspcud/gringo-4.4.0-1.el7.centos.x86_64.rpm -P /tmp/aspcud
            sudo rm -rf /usr/bin/aspcud
            sudo yum install -y /tmp/aspcud/*.rpm
            rm -rf /tmp/aspcud
            ;;
        *) echo "Nothing to be done for DISTRO=${DISTRO};"
            ;;
    esac
}

update_distro_packages()
{
    case "${DISTRO}" in
        centos*)
            sudo yum install -y epel-release
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

replace_centos_aspcud

if [ "${SAFE_STRING}" = 0 ]; then
   opam switch set 4.06.0+default-unsafe-string
   eval $(opam config env)
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
    opam install -y depext
    opam depext  -y $XS
    opam install -y -j 4 $XS
fi

