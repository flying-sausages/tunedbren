#!/bin/bash

name=$(basename $0)
filetypes="mp3 flac"

flactag() {
	# flactag TAG FILE returns the content of that tag in a FLAC file
	metaflac --export-tags-to=- "$2" | egrep -i "${1}=" | cut -d '=' -f 2- | awk 'BEGIN {OUT=""} {if(NR==1)(OUT=$0) else {OUT=" & "$0} END {print OUT;}'
}

check_dependencies() {
	# Little sanity check for executables that we need...
	DEPENDENCIES="id3convert mp3info metaflac egrep cut awk sed"
	for dep in $DEPENDENCIES
	do
		[ -z $(which $dep) ] && {
			echo "Missing dependency: ${dep}" 1>&2
			exit -99
		}
	done
}
check_dependencies

usage() {
	echo "$name [-option1 -option2 ... ] /path/to/files/"
	cat README.md 
}

# If there are no args...show usage
[[ $# -lt 1 ]] && { usage; exit -1; }


IN_DIR=''
DIR_TEMPLATE='%a - %l (%src %b) [%c %y]'
DIR_ARTIST=''
FILE_TEMPLATE='0%n. %a - %s'
FILE_ARTIST=''
ALBUM=''
CATALOG=''
YEAR=''
BITRATE=''
SOURCE=''
OUT_DIR=''

# Gather command line arguments by shifting them off one by one
while [ $# -gt 0 ]
do
	case "$1" in
		-t) shift; FILE_TEMPLATE="$1";
			;;
		-d) shift; DIR_TEMPLATE="$1";
			;;
		-a) shift; DIR_ARTIST="$1";
			;;
		-ta) shift; FILE_ARTIST="$1";
			;;
		-l) shift; ALBUM="$1";
			;;
		-c) shift; CATALOG="$1";
			;;
		-y) shift; YEAR="$1";
			;;
		-b) shift; BITRATE="$1";
			;;
		-src) shift; SOURCE="${1}^^";
			;;
		*) IN_DIR="$1";
			;;
	esac
	shift;
done

# A few sanity checks...
[ -z "$IN_DIR" ] && { echo "${name}: No input directory."; usage; exit -2 }
[ -d "$IN_DIR" ] || { echo "${name}: '$IN_DIR' is not a directory."; exit -3 }
[ -z "$FILE_TEMPLATE" ] && { echo "${name}: No file template."; exit -3 }
[ -z "$DIR_TEMPLATE" ] && { echo "${name}: No directory template."; exit -3 }

# Convert ID3 tags if there are any MP3 files
[ $(ls "$IN_DIR" | grep -q '\.mp3$') ] && { 
	id3convert "$IN_DIR"/*.mp3 || {
		echo "${name}: Failed to convert ID3 tags, continuing anyway."
	}
}

for filetype in filetypes
do
	ls "$IN_DIR"/*."$filetype" | while read infile
	do
		# Grab info from meta tags
		case filetype in
			mp3)
				[ -z "$FILE_ARTIST" ] && { FILE_ARTIST=$(mp3info -a "$infile"); }
				[ -z "$DIR_ARTIST" ] && { DIR_ARTIST="$FILE_ARTIST"; }
				[ -z "$ALBUM" ] && { ALBUM=$(mp3info -l "$infile"); }
				[ -z "$YEAR" ] && { YEAR=$(mp3info -y "$infile"); }
				[ -z "$BITRATE" ] && { BITRATE=$(mp3info -bitrate "$infile"); }
				;;
			flac)
				[ -z "$FILE_ARTIST" ] && { FILE_ARTIST=$(flactag ARTIST "$infile"); }
				[ -z "$DIR_ARTIST" ] && { DIR_ARTIST=$(flactag ALBUMARTIST "$infile"); }
				[ -z "$ALBUM" ] && { ALBUM=$(flactag ALBUM "$infile"); }
				[ -z "$YEAR" ] && { YEAR=$(flactag DATE "$infile"); }
				[ -z "$CATALOG" ] && { CATALOG=$(flactag CATALOGNUMBER "$infile"); }
				[ -z "$BITRATE" ] && { BITRATE="FLAC"; }
				;;
			*) echo "${name}: Unimplemented filetype $filetype"
				;;
		esac

		# Generate an output directory name, if there is none yet
		[ -z "$OUT_DIR" ] && {
			[ -z "$DIR_ARTIST" ] && { echo "Empty directory artist. Please set it using the -a parameter."; exit -4; }
			[ -z "$ALBUM" ] && { echo "Empty Album field. Please set it using the -l parameter."; exit -4; }
			[ -z "$CATALOG" ] && { echo "Empty Catalogue Number field. Please set it using the -c parameter."; exit -4; }
			[ -z "$YEAR" ] && { echo "Empty Year field. Please set it using the -y parameter."; exit -4; }
			[ -z "$BITRATE" ] && { echo "Empty Bitrate field. Please set it using the -b parameter."; exit -4; }
			[ -z "$SOURCE" ] && { echo "Empty Source field. Please set it using the -src parameter."; exit -4; }

			# TODO eval directory template
		}

		# TODO eval file template
	done
done


echo "Now give me source (WEB/Vinyl/CD/etc.)"
read source

# if there is a picture, rename it to cover.jpg or cover.png

# Capitalise source
sourceCaps=${source^^}}

newdir="${dir}../${artist} - ${album} (${source} ${bitrate}) [${catnr} $year]]"

echo "Moving to new dir = ${newdir}"
mv "$IN_DIR" "${newdir}"
