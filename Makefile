#
#
#

TOP :=  	$(PWD)
SRC := 		"$(TOP)/src"

repo: 	urls
	opam-admin make

urls: 	sources.txt
	grep -v '^#' $< | while read pkg url; do \
	  echo "http: \"file://$(SRC)/$$(basename $$url)\"" > packages/$$pkg/url;\
	done


SPEC 	+= xs-opam.spec
SPEC 	+= xs-opam-local.spec
SPEC 	+= xs-opam-build.spec
SPEC 	+= xs-opam-build-local.spec

spec: 	$(SPEC)

xs-opam.spec: xs-opam.in sources.txt
	awk '/^#/ {next}; /http/ { printf "Source%03d: %s\n", ++n, $$2}' sources.txt > sources.spec
	sed '/^# sources.spec/r sources.spec' $< > $@
	rm sources.spec

xs-opam-local.spec: xs-opam-local.in sources.txt
	awk '/^#/ {next}; /http/ { file=$$2; sub(".*/","", file); printf "Source%03d: http://localhost/src/%s\n", ++n, file}' sources.txt > local.spec
	sed '/^# local.spec/r local.spec' $< > $@
	rm local.spec

download:
	mkdir -p src
	cd src; awk '/^#/ {next}; {print $$2}' ../sources.txt | \
	while read url; do \
	      test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done

sources.draft:
	sh sources.sh > $@

clean:
	rm -rf archives
	rm -f urls.txt index.tar.gz 
	rm -f sources.draft
	rm -f xs-opam.spec xs-opam-local.spec

# private targets

sync: 	download spec
	rsync -r src/ /var/www/html/src
	cp $(SPEC) $(HOME)/src/xenserver-specs/SPECS
