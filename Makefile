#
# vim: set ts=8 sw=8 noet:
#

VERSION	:= $(shell git describe --tags | sed 's/-.*$$//')
RELEASE := $(shell git describe --tags)
PROJECT := ~CHRISTIANLIN

REPO	:= https://code.citrite.net/rest/archive/latest/projects/$(PROJECT)/repos/xs-opam/archive?at=$(VERSION)\&format=tar.gz\#/xs-opam-rpm-$(VERSION).tar.gz
URL	+= packages/upstream/*/url
URL	+= packages/xs/*/url
MIRROR	:= https://repo.citrite.net/ctx-local-contrib/xs-opam/
SRCS 	:= ./utils/sources.rb -m "$(MIRROR)" $(URL)

TOP	:= $(PWD)
SRC	:= $(TOP)/build/src

# default target

all:	check spec

#
# build an Opam repo in build/ with all URL files pointing
# to sources in build/src.
#
repo:	build packages
	cp -r packages build
	$(SRCS) | while read pkg url; do \
		echo "http: \"file://$(SRC)/$$(basename $$url)\"" > build/packages/$$pkg/url;\
	done
	cd build; opam-admin make


# This target provides the Opam package description under
# packages/. We have two scenarios: (1) this Makefile is called
# from xs-opam-src.spec, in which case the public repo is part
# of the sources in build/src. (2) otherwise we need to download it.
#
packages: build
	if test -d packages; then 			\
		echo "packages exist already" 		;\
	elif test -f build/src/xs-opam.tar.gz; then 	\
		tar zxf build/src/xs-opam.tar.gz 	;\
		mv xs-opam-master/packages . 		;\
	else 						\
		wget https://github.com/xapi-project/xs-opam/archive/master/xs-opam.tar.gz ;\
		tar zxf xs-opam.tar.gz 			;\
		mv xs-opam-master/packages . 		;\
	fi

build:
	mkdir -p build/src

# generate spec files
spec: 	packages
	git diff --quiet HEAD || ( echo "uncommitted changes" && false )
	$(SRCS) |\
	awk 'BEGIN {n=10} /http/ { printf "Source%03d: %s\n", n++, $$2}' > sources.spec
	sed	-e '/^# sources.spec/r sources.spec'	\
		-e 's!@VERSION@!$(VERSION)!'		\
		-e 's!@RELEASE@!$(RELEASE)!'		\
		-e 's!@REPO@!$(REPO)!'			\
		-e 's!@URL@!$(URL)!'			\
		-e 's!@MIRROR@!$(MIRROR)!'		\
		xs-opam-src.in > xs-opam-src.spec
	rm -f sources.spec
	sed	-e 's!@VERSION@!$(VERSION)!'		\
		-e 's!@RELEASE@!$(RELEASE)!'		\
		-e 's!@DATE@!$(DATE)!'			\
		-e 's!@MIRROR@!$(MIRROR)!'		\
		-e 's!@URL@!$(URL)!'			\
		-e 's!@REPO@!$(REPO)!'			\
		xs-opam-repo.in > xs-opam-repo.spec

# check all URLs using the HTTP HEAD command but don't download.
# all URLs are checked in parallel
check:  packages
	$(SRCS) |						\
	while read package url; do				\
		( curl -sS --head --fail $$url > /dev/null;	\
		if [ ! $$? -eq 0 ]; then echo; echo $$f; fi;) & \
	done ;							\
	wait
	echo done

# download all archives but skip those that are already present
download: packages build
	$(SRCS) | 					\
	while read package url; do 			\
		cd $(SRC); 				\
		test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done
	cd $(SRC) && wget https://github.com/xapi-project/xs-opam/archive/master/xs-opam.tar.gz

# generate URLs for debugging
sources.txt: packages
	$(SRCS) > $@

clean:
	rm -rf build packages
	rm -f sources.spec sources.txt
	rm -f xs-opam-src.spec xs-opam-repo.spec


