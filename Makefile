#
#
#

TOP :=  	$(PWD)
SRC := 		"$(TOP)/src"
OPAMROOT := 	/tmp/opam-root

repo: 	urls
	opam-admin make

urls: 	sources.txt
	grep http $< | while read pkg url; do \
	  echo "http: \"file://$(SRC)/$$(basename $$url)\"" > packages/$$pkg/url;\
	done

build:
	mkdir -p $(OPAMROOT)
	env OPAMROOT=$(OPAMROOT) opam init -n
	env OPAMROOT=$(OPAMROOT) opam repo add local .
	env OPAMROOT=$(OPAMROOT) opam update -u -y
	env OPAMROOT=$(OPAMROOT) opam install -y rpc

sources.spec: sources.txt
	awk '/http/ { printf "Source%03d: %s\n", ++n, $$2}' $< > sources.spec

