#
#
#

SRC = 	"$(PWD)/src"

repo: 	urls
	opam-admin make

urls: 	sources.txt
	grep http $< | while read pkg url; do \
	  echo "http: \"file://$(SRC)/$$(basename $$url)\"" > packages/$$pkg/url;\
	done

