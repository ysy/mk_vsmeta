#!/bin/bash

ext=mp4
IFS=$'\n'

i=1

rm -rf out
mkdir -p out/vsmeta

tvshow_name=$1
season=$1


ep_rule='#([0-9]{2})'
name_rule="#[0-9]{2} l(.*)l Tayo the"
remove="英语1080P(限免)"
#name_cmd_rule='{print $4}'

mv revert.sh revert.sh.bak
rm -rf revert.sh

for f in `find -name "*.${ext}" -type f ` ; do 
	filename=$(basename "$f")
	if [ -n "$ep_rule" ]; then
		ep_num=$(echo "$filename" | awk "{match(\$0, /$ep_rule/, a); print a[1]}")
	else
		ep_num=${i}
		((i++))
	fi
	
	if [ -n "$name_rule" ]; then
		name=$(echo "$filename" | awk "{match(\$0, /$name_rule/, a); print a[1]}")
	fi

	if [ -n "$season_rule" ]; then
		season=$(echo "$filename" | awk "{match(\$0, /$season_rule/, a); print a[1]}")
	fi

	if [ -n "$name_cmd_rule" ]; then
		key=$(echo $ep_num | sed 's/^0//')
		key="第${key}集"
		name=$(cat names.txt | grep $key | awk "$name_cmd_rule" )
		echo dafs
	fi

	name=$(echo $name | sed "s/$remove//g")
	name=$(echo $name | sed "s/$ext//g")
	name=$(echo $name | sed "s/\[.*\.com\.cn]//g" )
	name=$(echo $name | sed "s/[ \.]$//g" )
	name=$(echo $name | sed "s/^[\. ]//g" )
	newfilename=$tvshow_name.S${season}E${ep_num}.${name}.${ext}
	
	name=$(echo $name | sed 's/[\._-]/ /g' )
	echo $season $ep_num $name $newfilename
	if [ -z $tvshow_name ]  || [ $tvshow_name = "test" ]; then
		echo skip
		continue
	fi
	echo mv  "${newfilename}" "$f" >> revert.sh
	#mv -v  -b "$f" "${newfilename}"
	ln  "$f" "out/${newfilename}"
	  ~/mk_vsmeta  -s $season -e $ep_num -t $tvshow_name -n $name  "out/vsmeta/${newfilename}.vsmeta"
done

