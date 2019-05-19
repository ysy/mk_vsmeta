#!/bin/bash

IFS=$'\n'
rm -rf out
mkdir -p out

i=1
tvshow_title=$1
for f in `cat file.list` ; do 
	dir=$(dirname $f)
	mkdir -p out/$dir
	filename=$(basename $f)
	filename=${filename%.*}
	season=$(echo $filename | awk '{match($0, /S([0-9]*)/, a); print a[1]}') 
	ep=$(echo $filename | awk '{match($0, /E([0-9]*)/, a); print a[1]}') 
	title=$(echo $filename | awk '{match($0, /E[0-9]*\.*(.*)\..*/, a); print a[1]}') 
	
	if [ -z $season ]; then
		season="03"
		#tvshow_title="Backkom 2"
		ep=${filename:0:2}
			
		#ep=$(echo $filename | awk '{match($0, /([0-9]*)/, a); print a[1]}') 
		#title=""
		#title=$(echo $filename | awk '{match($0, /([0-9]*)/, a); print a[1]}') 
		#echo $ep
		title=${filename:12}
		title=${title%.*}	
		title=${title%_720p*}	
		#echo $title
	fi

	if [ -z $ep ]; then
		season="0"
		ep=$i;
		((i++))
		title=$(echo $filename | awk '{match($0, /S[0-9]*\.*(.*)\..*/, a); print a[1]}') 
	fi
	title=${title%.1080p*}
        title=${title%_1080*}
        title=${title%.720p*}

	#echo $filename $season $ep $title
	title=$(echo $title | sed "s/ /\./g ") # replace space
	if [ -n $title ]; then title_option="-n $title" ; fi
	echo  ./mk_vsmeta -s $season -e $ep -t $tvshow_title $title_option  out/$dir/$filename.vsmeta
        ./mk_vsmeta -s $season -e $ep -t $tvshow_title $title_option  out/$dir/$filename.vsmeta
done

cd out
tar zcf  vsmeta.tar.gz  *
