#
#

SHELL   = /bin/bash
VERSION = $(shell git describe --abbrev=0 --tags)
NAME 	= xs-opam-repo-$(VERSION)

.PHONY: all archive clean

all:
	docker build -f tools/Dockerfile -t xenserver/xs-opam:$(VERSION) .

archive: $(NAME).tar.gz

$(NAME).tar.gz:
	# don't package ocaml, do package cache
	mv packages/ocaml .
	mv packages/upstream-extra .
	env OPAMFETCH=wget opam admin cache |& tee cache.log
	git archive --format=tar.gz --prefix=$(NAME)/ HEAD > $@
	tar zxf $@
	cd $(NAME) && ln -fs ../cache .
	tar czhf $@ $(NAME)
	mv ocaml packages
	mv upstream-extra packages

clean:
	rm -f  $(NAME).tar.gz
	rm -rf $(NAME)


# vim: set noet ts=8:
