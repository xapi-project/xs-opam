#! /bin/bash
# create a draft for sources.txt

set -e

cd packages 
find * -type f -name url -print | while read f 
do 
  pkg=$(dirname $f)
  url=$(egrep '^(http|archive|git|src):' $f | grep -o '".*"' | tr -d '"') 
  echo "$pkg $url"
done | sort | uniq | column -t 
