# Disable internal dependency generator as it doesn't work for this RPM
# The problem is that there are multiple modules with the same name
# and this confuses the dependency script

Name: xs-opam-repo
Version: 0.0.3
Release: 1%{?dist}
Summary: Build and install all OCaml libraries
License: Various
URL: http://github.com/lindig/xs-opam
AutoReqProv: no

# BuildRequires: xs-opam-src-local
BuildRequires: xs-opam-src

BuildRequires: opam
BuildRequires: rsync
BuildRequires: ocaml
BuildRequires: ocaml-camlp4
BuildRequires: ocaml-camlp4-devel
BuildRequires: ocamldoc
BuildRequires: rsync
BuildRequires: m4
BuildRequires: git
BuildRequires: aspcud
BuildRequires: gringo
BuildRequires: clasp
BuildRequires: zlib-devel
BuildRequires: autoconf
BuildRequires: gmp
BuildRequires: gmp-devel
BuildRequires: openssl-devel
BuildRequires: libffi-devel
BuildRequires: systemd-devel
BuildRequires: hwdata
BuildRequires: pciutils-devel
BuildRequires: libnl3
BuildRequires: xen-ocaml-devel


%description
Opam repository that contains all libraries necessary to compile XenServer 
Toolstack components.

%prep

%build

# upstream libraries
PKG=""
PKG="$PKG $(ls -1 /usr/share/opam-repository/packages/upstream)"
PKG="$PKG $(ls -1 /usr/share/opam-repository/packages/xs)"

export OPAMROOT=/usr/lib/opamroot
opam init -y 
opam config exec -- opam repository add local file:///usr/share/opam-repository
opam config exec -- opam install -j 8 -y $PKG

%install
mkdir -p %{buildroot}/usr/lib/opamroot/
rsync -avz /usr/lib/opamroot/ %{buildroot}/usr/lib/opamroot/
rm -rf %{buildroot}/usr/lib/opamroot/log/*
rm -rf %{buildroot}/usr/lib/opamroot/system/build/*

%files
%exclude /usr/lib/opamroot/system/lib/*/*.cmt
%exclude /usr/lib/opamroot/system/lib/*/*.cmti
%exclude /usr/lib/opamroot/system/lib/*/*.annot
%exclude /usr/lib/opamroot/repo/*/archives
%exclude /usr/lib/opamroot/archives
/usr/lib/opamroot

%changelog
* Tue Dec 20 2016 Christian Lindig <christian.lindig@citrix.com> - 0.0.1-1
- Initial version
