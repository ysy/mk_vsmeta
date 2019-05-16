#!/bin/bash


# ./do.sh orign.list new.list tvshow_title 

oldlist=$1
newlist=$2
tvshow_title=$3

IFS=$'\n';

rm filenames.txt
rm cmd.sh
rm cmd_tmp.txt
rm oldlist.tmp


rm -rf vsmeta
mkdir vsmeta

for f in `cat $newlist ` ; do 
	f=`basename $f` ;
	season=${f:0:4} 
	episode=${f:5:2} 
	tail_str=${f:7}
	episode_title=${tail_str%.*}
	ext=${tail_str##*.}

	newfilename=${tvshow_title}.S${season}.E${episode}-${episode_title}
	echo \"${newfilename}.${ext}\" >> filenames.txt
	
	etitle_option=""

	if [ -n $episode_title ] ; then
		etitle_option="-n $episode_title"
		echo $etitle_option
	fi
	echo "$newfilename"
	./mk_vsmeta -s ${season} -e ${episode} -t ${tvshow_title} $etitle_option "vsmeta/${newfilename}.${ext}.vsmeta"  
done

for line in `cat $oldlist` ; do 
	echo \"$line\" >> oldlist.tmp
done

paste oldlist.tmp filenames.txt > cmd_tmp.txt

for line in `cat cmd_tmp.txt` ; do 
	echo "mv $line" >> cmd.sh
done	

rm cmd_tmp.txt
rm oldlist.tmp

tar zcvf vsmeta.tar.gz  vsmeta
