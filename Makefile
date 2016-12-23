#
#
#

TOP :=  	$(PWD)
SRC := 		"$(TOP)/src"

repo: 	sources.txt
	rm -rf packages
	cp -r packages.orig packages
	grep -v '^#' $< | while read pkg url; do \
	  echo "http: \"file://$(SRC)/$$(basename $$url)\"" > packages/$$pkg/url;\
	done
	opam-admin make

SPEC 	+= xs-opam-src.spec
SPEC 	+= xs-opam-src-local.spec
SPEC 	+= xs-opam-repo.spec

spec: 	$(SPEC)

xs-opam-src.spec: xs-opam-src.in sources.txt
	awk '/^#/ {next}; /http/ { printf "Source%03d: %s\n", ++n, $$2}' sources.txt > sources.spec
	sed '/^# sources.spec/r sources.spec' $< > $@
	rm sources.spec

xs-opam-src-local.spec: xs-opam-src-local.in sources.txt
	awk '/^#/ {next}; /http/ { file=$$2; sub(".*/","", file); printf "Source%03d: http://localhost/src/%s\n", ++n, file}' sources.txt > local.spec
	sed '/^# local.spec/r local.spec' $< > $@
	rm local.spec

# download all archives that are not there already
download:
	mkdir -p src
	cd src; awk '/^#/ {next}; {print $$2}' ../sources.txt | \
	while read url; do \
	      test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done

# remove all archives that are likely to track a repo
expunge:
	cd src; awk '/^#/ {next}; {print $$1, $$2}' ../sources.txt | \
	while read pkg url; do \
		case $$pkg in *master*) rm $$(basename $$url);; esac \
	done

sources.draft:
	sh sources.sh > $@

clean:
	rm -rf archives packages
	rm -f urls.txt index.tar.gz 
	rm -f sources.draft
	rm -f xs-opam-src.spec xs-opam-src-local.spec

# private targets

sync: 	download spec
	rsync -r src/ /var/www/html/src
	cp $(SPEC) $(HOME)/src/xenserver-specs/SPECS

missing: installed
	cat installed | while read p v; do \
	f=$$p.$$v; \
	test -d packages/xs/$$f \
	|| test -d packages/upstream/$$f \
	|| echo $$f; \
	done
