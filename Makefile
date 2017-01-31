#
#
#

DATE    := $(shell printf '%x' `date +%s`)
RELEASE := $(shell git describe --always)
VERSION := 0.0.$(DATE)

TOP	:= $(PWD)
SRC	:= "$(TOP)/build/src"

SPEC	+= xs-opam-src.spec
SPEC	+= xs-opam-repo.spec


all: repo spec

#
# build an Opam repo in build/ with all URL files pointing
# to sources in build/src.
#
repo:	sources.txt build
	cp -r packages build
	grep -v '^#' $< | while read pkg url; do \
		echo "http: \"file://$(SRC)/$$(basename $$url)\"" > build/packages/$$pkg/url;\
	done
	cd build; opam-admin make

build:
	mkdir -p build/src


# generate spec files
spec:
	awk '/^#/ {next}; /http/ { printf "Source%03d: %s\n", ++n, $$2}' sources.txt > sources.spec
	sed -e '/^# sources.spec/r sources.spec' \
		-e 's/@VERSION@/$(VERSION)/' xs-opam-src.in > xs-opam-src.spec
	rm sources.spec
	sed -e 's/@VERSION@/$(VERSION)/' xs-opam-repo.in > xs-opam-repo.spec

# download all archives but skip those that are already present
download: build
	cd $(SRC); awk '/^#/ {next}; {print $$2}' ../../sources.txt | \
	while read url; do \
		test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done

# update sources.txt by reading all URL files and checking the URL
update:
	find packages -name url -type f | \
		xargs ./utils/sources.rb | sort | column -t > sources.tmp
	awk '{print $$2}' sources.tmp | while read f; do \
		curl -sS --head --fail $$f > /dev/null; \
		echo -n . ;\
		if [ ! $$? -eq 0 ]; then echo; echo $$f; fi \
	done
	diff sources.txt sources.tmp || true
	mv sources.tmp sources.txt

clean:
	rm -rf build
	rm -f xs-opam-src.spec xs-opam-repo.spec


