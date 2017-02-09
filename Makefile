#
# vim: set ts=8 sw=8 noet:
#

VERSION	:= 0.2.1

REPO	:= https://github.com/xapi-project/xs-opam
DATE	:= $(shell printf '%x' `date +%s`)
RELEASE	:= $(shell git describe --always)
URL	+= packages/upstream/*/url
URL	+= packages/xs/*/url
MIRROR	:=
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
		echo "http: \"file://$(SRC)/$$(basename $$url)\"" > build/packages/$$pkg/url;\
	done
	cd build; opam-admin make

build:
	mkdir -p build/src

# generate spec files
spec:
	git diff --quiet HEAD || ( echo "uncommitted changes" && false )
	git tag $(VERSION) || echo "consider incrementing the VERSION"
	$(SRCS) |\
	awk '/http/ { printf "Source%03d: %s\n", ++n, $$2}' > sources.spec
	sed	-e '/^# sources.spec/r sources.spec'	\
		-e 's/@VERSION@/$(VERSION)/'		\
		-e 's/@RELEASE@/$(RELEASE)/'		\
		-e 's!@REPO@!$(REPO)!'			\
		-e 's!@URL@!$(URL)!'			\
		-e 's!@MIRROR@!$(MIRROR)!'		\
		xs-opam-src.in > xs-opam-src.spec
	rm -f sources.spec
	sed	-e 's/@VERSION@/$(VERSION)/'		\
		-e 's/@RELEASE@/$(RELEASE)/'		\
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
	$(SRCS) | 					\
	while read package url; do 			\
		cd $(SRC); 				\
		test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done

# generate URLs for debugging
sources.txt:
	$(SRCS) > $@

clean:
	rm -rf build
	rm -f sources.spec sources.txt
	rm -f xs-opam-src.spec xs-opam-repo.spec


