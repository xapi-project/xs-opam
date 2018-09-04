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

enable_centos_virt_xen()
{
    case "${DISTRO}" in
        centos*)
            sudo cp /xs-opam/tools/CentOS-Xen.repo /etc/yum.repos.d/
            sudo cp /xs-opam/tools/RPM-GPG-KEY-CentOS-SIG-Virtualization /etc/pki/rpm-gpg/
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

enable_centos_virt_xen

if [ "${SAFE_STRING}" = 0 -a "${OCAML_VERSION:0:4}" = "4.06" ]; then
   opam switch create 4.06.0+default-unsafe-string
   eval $(opam config env)
fi

if [ ! "${BASE_REMOTE}" = "" ]; then
    opam repo remove --all default
    opam repo add base "$BASE_REMOTE"
fi

if [ ! "${EXTRA_REMOTES}" = "" ]; then
    opam repo add extra "$EXTRA_REMOTES"
fi

if [ "${OPAM_LINT}" = 1 ]; then
    find packages -iname opam -print | xargs -n 1 opam lint
elif [ "${CHECK_UNUSED}" = 1 ]; then
    opam install -y --fake $XS $(pkg xs-extra-dummy)
    # Fail if there are unused packages in $UPSTREAM:
    AVAILABLE=$(pkg upstream | sed 's/\..*$//' | sort -u)
    INSTALLED=$(opam list | grep -v \# | cut -d' ' -f1 | sort -u)
    UNNEEDED=$(comm -23 <(echo "$AVAILABLE") <(echo "$INSTALLED"))
    if [ -n "$UNNEEDED" ]; then
        echo Unused packages in upstream/: $UNNEEDED
        exit 1
    fi
elif [ "${CHECK_TEST_DEPENDENCIES}" = 1 ]; then
    opam install -t -y --fake $XS
else
    opam install -y depext
    opam depext  -y $XS
    opam install -y -j 4 $XS
fi
