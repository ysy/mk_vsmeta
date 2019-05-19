#!/bin/bash

IFS=$'\n'  #to fix space in filenames
function print_usage
{
	echo "./do.sh  -s season_rule -e ep_rule  -E mp4 -r 'xxx'  TVSHOW_NAME"

	echo "-s season_rule to extract season"
	echo "-e ep rule to extrace ep_num"
	echo "-n name rule"
	echo "-E file extension"
	echo "-t test run"
	echo "-S fixed season"
	echo "--std standard S01E01 ep/season rule"
}


for arg in "$@"; do
  shift
  case "$arg" in
    "--help")   set -- "$@" "-h" ;;
    "--ext")    set  -- "$@" "-E" ;;
    "--remove") set -- "$@" "-r" ;;
	"--std") 	set -- "$@" "-T" ; echo "STD" ;;
    *)          set -- "$@" "$arg"
  esac
done

# Default behavior
ext="mp4"
##name_remove=""
test_run="false"

STD_EP_RULE="E([0-9]+)"
STD_SEASON_RULE="S([0-9]+)E"
STD_NAME_RULE="E[0-9]+[\._-](.*)\..{2,4}$"

# Parse short options
OPTIND=1
while getopts "hs:e:r:n:tE:S:T" opt
do
  case "$opt" in
    "h") print_usage; exit 0 ;;
    "r") name_remove=${OPTARG} ;;
	"n") name_rule=${OPTARG} ;;
	"s") season_rule=${OPTARG} ; echo $season_rule; ;;
	"e") ep_rule=${OPTARG} ;;
	"t") test_run=true;;
	"E") ext=$OPTARG;;
	"S") fixed_season=$OPTARG;;
	"T") ep_rule=$STD_EP_RULE; season_rule=$STD_SEASON_RULE; ;;
    "?") print_usage >&2; exit 1 ;;
  esac
done

shift $(expr $OPTIND - 1) # r

if [ -z $ep_rule ] || [ -z $season_rule ] ; then
	echo $ep_rule;
	echo $season_rule;
	echo "EP rule and season rule can not be empty"
	print_usage;
	exit 2;
fi


if [ -z $name_rule ]  && [ $ep_rule = $STD_EP_RULE ]; then
	name_rule=$STD_NAME_RULE;
	echo "STDNAMERUL"
fi

#ext=mp4
IFS=$'\n'

i=1

rm -rf out
mkdir -p out/vsmeta

tvshow_name=$1

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
		echo $season;
	fi

	if [ -n "$fixed_season" ]; then season=$fixed_season; fi


	if [ -n "$name_cmd_rule" ]; then
		key=$(echo $ep_num | sed 's/^0//')
		key="第${key}集"
		name=$(cat names.txt | grep $key | awk "$name_cmd_rule" )
		echo dafs
	fi

	if [ -n "$name" ] ; then
		echo $name
		if [ -n "$name_remove" ]; then
			name=$(echo $name | sed "s/$name_remove//g")
		fi
		if [ -n "$ext" ] ; then
			name=$(echo $name | sed "s/$ext//g")
		fi
		name=$(echo $name | sed "s/\[.*\.com\.cn]//g" )
		name=$(echo $name | sed "s/\[.*\.com]//g" )
		name=$(echo $name | sed "s/[ \.]$//g" )
		name=$(echo $name | sed "s/^[\. ]//g" )
	fi
	newfilename=$tvshow_name.S${season}E${ep_num}.${name}.${ext}

	name=$(echo $name | sed 's/[\._-]/ /g' )
	echo -e "$season | $ep_num | $name\t|$newfilename"
	if [ -z $tvshow_name ]  || [ $tvshow_name = "test" ] || [ $test_run = "true" ]; then
		echo skip
		continue
	fi
	echo mv  "${newfilename}" "$f" >> revert.sh
	#mv -v  -b "$f" "${newfilename}"
	ln  "$f" "out/${newfilename}"
	 ~/mk_vsmeta  -s $season -e $ep_num -t $tvshow_name -n $name  "out/vsmeta/${newfilename}.vsmeta"
done

