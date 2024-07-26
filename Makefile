#
#

SHELL   = /bin/bash
VERSION = $(shell git describe --tags)
NAME 	= xs-opam-repo-$(VERSION)

.PHONY: all archive clean licenses

all:
	docker build -f tools/Dockerfile -t xenserver/xs-opam:$(VERSION) .

archive: $(NAME).tar.gz

$(NAME).tar.gz:
	# Add only upstream and xs pkgs into cache, add ocaml ones to metadata
	mkdir -p stash/ocaml
	mv packages/{upstream-extra,xs-extra,xs-extra-dummy} stash
	mv packages/ocaml/ocaml-base-compiler.* stash/ocaml
	env OPAMFETCH=curl opam admin cache |& tee cache.log
	! grep ERROR cache.log
	tar zcf $@ --transform "flags=r;s|^|$(NAME)/|" cache packages tools repo
	cp -R stash/* packages/
	rm -R stash/

# report licenses of xs-toolstack from *installed* packages
licenses:
	./tools/licenses.sh | column -s: -t

nolicense:
	./tools/licenses.sh | grep ': *$$' || true

clean:
	rm -f  $(NAME).tar.gz
	rm -rf $(NAME)


# vim: set noet ts=8:
