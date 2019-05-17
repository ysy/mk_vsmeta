#!/bin/bash

IFS=$'\n'
rm -rf out
mkdir -p out
tvshow_title=$1
for f in `cat file.list` ; do 
	dir=$(dirname $f)
	mkdir -p out/$dir
	filename=$(basename $f)
	filename=${filename%.*}
	season=$(echo $filename | awk '{match($0, /S([0-9]*)/, a); print a[1]}') 
	ep=$(echo $filename | awk '{match($0, /E([0-9]*)/, a); print a[1]}') 
	title=$(echo $filename | awk '{match($0, /E[0-9]*\.*(.*)\..*/, a); print a[1]}') 
	title=${title%.1080p*}	
	#echo $filename $season $ep $title
	title=$(echo $title | sed "s/ /\./g ") # replace space
	if [ -n $title ]; then title_option="-n $title" ; fi
	echo ./mk_vsmeta -s $season -e $ep -t $tvshow_title $title_option  out/$dir/$filename.vsmeta
done
