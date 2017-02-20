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
repo:	build
	cp -r packages build
	$(SRCS) | while read pkg url; do \
		mv build/packages/$$pkg/url build/packages/$$pkg/url.off ;\
		echo "http: \"file://$(SRC)/$$(basename $$url)\"" > build/packages/$$pkg/url;\
	done
	cd build; opam-admin make
	cd build; find packages -type f -name 'url.off' -execdir mv '{}' url ';'

build:
	mkdir -p build/src

# generate spec files
spec:
	git diff --quiet HEAD \
		|| ( echo "uncommitted changes" && false )
	git diff --quiet master:packages public:packages \
		|| ( echo "update packages on branch public" && false )
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
check:
	$(SRCS) |						\
	while read package url; do				\
		( curl -sS --head --fail $$url > /dev/null;	\
		if [ ! $$? -eq 0 ]; then echo; echo $$f; fi;) & \
	done ;							\
	wait
	echo done

# download all archives but skip those that are already present
download: build
	./utils/sources.rb $(URL) | 			\
	while read package url; do 			\
		cd $(SRC); 				\
		test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done

# find differences between master and public repo
diff:
	git diff master:packages public:packages

# generate URLs for debugging
sources.txt:
	$(SRCS) > $@

clean:
	rm -rf build
	rm -f sources.spec sources.txt
	rm -f xs-opam-src.spec xs-opam-repo.spec


