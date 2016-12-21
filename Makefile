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

sources.spec: sources.txt
	awk '/^#/ {next}; /http/ { printf "Source%03d: %s\n", ++n, $$2}' $< > sources.spec

sources.draft:
	sh sources.sh > $@

download:
	mkdir -p src
	cd src; awk '/^#/ {next}; {print $$2}' ../sources.txt | \
	while read url; do \
	      test -f $$(basename $$url) || curl --fail -L -O $$url; \
	done

clean:
	rm -f archives urls.txt index.tar.gz 
