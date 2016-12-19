#
#
#

THIS = 	"$(PWD)/src"

repo: 	urls
	opam-admin make

urls: 	sources.txt
	grep http $< | while read pkg local url; do \
	  echo "http: \"file://$(THIS)/$$(basename $$url)\"" > packages/$$pkg/url;\
	done

