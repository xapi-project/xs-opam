#
# vim: set ts=8 sw=8 noet:
#

#
# override for testing using a personal repository:
#
# 	make REPO=http://github.com/lindig/xs-opam spec
#
REPO	:= https://github.com/xapi-project/xs-opam

DATE    := $(shell printf '%x' `date +%s`)
RELEASE := $(shell git describe --always)
VERSION := 0.1.$(DATE)

TOP	:= $(PWD)
SRC	:= $(TOP)/build/src

SPEC	+= xs-opam-src.spec
SPEC	+= xs-opam-repo.spec


all: 	check spec

#
# build an Opam repo in build/ with all URL files pointing
# to sources in build/src.
#
repo:	build
	cp -r packages build
	./utils/sources.rb packages/*/*/url | while read pkg url; do \
		echo "http: \"file://$(SRC)/$$(basename $$url)\"" > build/packages/$$pkg/url;\
	done
	cd build; opam-admin make

build:
	mkdir -p build/src

# generate spec files
spec:
	./utils/sources.rb packages/*/*/url |\
	awk '/http/ { printf "Source%03d: %s\n", ++n, $$2}' > sources.spec
	sed	-e '/^# sources.spec/r sources.spec'	\
		-e 's/@VERSION@/$(VERSION)/'		\
		-e 's/@RELEASE@/$(RELEASE)/'		\
		-e 's!@REPO@!$(REPO)!'			\
		xs-opam-src.in > xs-opam-src.spec
	rm -f sources.spec
	sed	-e 's/@VERSION@/$(VERSION)/'		\
		-e 's/@RELEASE@/$(RELEASE)/'		\
		-e 's!@REPO@!$(REPO)!'			\
		xs-opam-repo.in > xs-opam-repo.spec

# check all URLs using the HTTP HEAD command but don't download
# all URLs are checked in parrallel
check:
	./utils/sources.rb --url packages/*/*/url | 		\
	while read f; do 					\
		( curl -sS --head --fail $$f > /dev/null; 	\
		if [ ! $$? -eq 0 ]; then echo; echo $$f; fi;) & \
	done ;							\
	wait
	echo done

# download all archives but skip those that are already present
download: build
	cd $(SRC); ../../utils/sources.rb ../../packages/*/*/url --url |\
	while read url; do \
		test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done

# generate URLs for debugging
sources.txt:
	./utils/sources.rb packages/*/*/url > $@

clean:
	rm -rf build
	rm -f sources.spec sources.txt
	rm -f xs-opam-src.spec xs-opam-repo.spec


