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

clean:
	rm -f archives urls.txt index.tar.gz 
