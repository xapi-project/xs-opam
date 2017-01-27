#! /bin/sed -f
# rewrite GitHub archive links to use sensible file name

s!github.com/\([^/]*\)/\([^/]*\)/archive/\([-.0123456789v+]*\).tar.gz!github.com/\1/\2/archive/\3/\2-\3.tar.gz!
s!git://github.com/\([^/]*\)/\([^/#]*\)$!https://github.com/\1/\2/archive/master/\2-master.tar.gz!
s!git://github.com/\([^/]*\)/\([^/#.]*\)\(.git\)*#\([a-z-]*\)!https://github.com/\1/\2/archive/\4/\2-\4.tar.gz!

