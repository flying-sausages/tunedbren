#!/bin/bash

name=$(basename $0)
filetypes="mp3 flac"
check_dependencies() {
	# Little sanity check for executables that we need...
	DEPENDENCIES="id3convert mp3info metaflac"
	for dep in $DEPENDENCIES
	do
		[ -z $(which $dep) ] && {
			echo "Missing dependency: ${dep}" 1>&2
			exit -99
		}
	done
}

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
		-src) shift; SOURCE="$1";
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
		case filetype in
			mp3) 
				;;
			flac)
				;;
			*) echo "${name}: Unimplemented filetype $filetype"
				;;
		esac
	done
done


#echo "Wanna check and possibly edit the tags before we move all this shit? [N/y]"
# If yes, read out song nr, track, artist, album and year into stdout
# Ask if correct
    # if not, ask for track numbers to edit or leave blank to edit the entire thing
            #maybe wipe all tags? Ask which ones should remain?
            #Ask which fields áre the same for all files
            #Apply all common tags
            #Have user fill out the remaining tags one by one


#Rename to specified standards

#Get whatever info you can from the files
artist=$(mp3info -a *.mp3)
album=$(mp3info -l *.mp3)
year=$(mp3info -y *.mp3)
bitrate=$(mp3info -bitrate *.mp3)

#Ask for things you can't export from the tags
echo "Write CAT# plox"
read catnr

echo "Now give me source (WEB/Vinyl/CD/etc.)"
read source

# if there is a picture, rename it to cover.jpg or cover.png

# Capitalise source
sourceCaps=${source^^}}

newdir="${dir}../${artist} - ${album} (${source} ${bitrate}) [${catnr} $year]]"

echo "Moving to new dir = ${newdir}"
mv "$IN_DIR" "${newdir}"
