Name: xs-opam
Version: 0.0.1
Release: 1%{?dist}
Summary: Opam repository
License: Various
URL: http://localhost/src/

Source000: https://github.com/lindig/xs-opam/archive/master/xs-opam-master.tar.gz

# generate this list with "make sources.spec"
Source001: http://github.com/jonludlam/ocaml-rpc/archive/ppx2/ocaml-rpc.tar.gz
Source002: http://github.com/jonludlam/shared-block-ring/archive/ppx/shared-block-ring.tar.gz

BuildRequires: opam
BuildRequires: rsync

%description
Opam repository containing all upstream and development libraries
required for building the OCaml components in the XS Toolstack.

%prep
%setup -q -n xs-opam
# link all source files into src/
mkdir src
grep -v '^#' sources.txt | while read p url
do
  file=$(basename $url)
  (cd src; test -f $file || ln -s ../../../SOURCES/$file .)
done
# rename all URL files such that we only use archive
find packages -type f -name url -exec mv {} {}.off \;

%build
make

%install
mkdir -p %{buildroot}/usr/share/opam-repository
rsync -avz  archives packages %{buildroot}/usr/share/opam-repository/
chmod o+w -R %{buildroot}/usr/share/opam-repository

# create opam root
mkdir -p %{buildroot}/usr/lib/opamroot
chmod 777 %{buildroot}/usr/lib/opamroot


%files
/usr/share/opam-repository
/usr/lib/opamroot
%attr(777, root, root) /usr/lib/opamroot

%changelog
* Tue Dec 20 2016 Christian Lindig <christian.lindig@citrix.com> - 0.0.1-1 
- Initial version

