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
	# Remove unneeded packages (like dev tools), and retain special packages
	opam admin filter --recursive --required-by xs-toolstack --or host-system-other -y
	# Remove all xapi dev packages
	opam admin filter '*.master' --remove -y
	# Remove compilable ocaml versions
	opam admin filter 'ocaml-base-compiler' --remove -y
	# Remove xen-related packages, the libraries are built by the xen package
	opam admin filter 'conf-xen' --remove -y
	opam admin cache |& tee cache.log
	! grep ERROR cache.log
	tar zcf $@ --transform "flags=r;s|^|$(NAME)/|" cache packages tools repo
	# restore removed packages
	git checkout -- packages

# report licenses of xs-toolstack from *installed* packages
licenses:
	./tools/licenses.sh | column -s: -t

nolicense:
	./tools/licenses.sh | grep ': *$$' || true

clean:
	rm -f  $(NAME).tar.gz
	rm -rf $(NAME)


# vim: set noet ts=8:
