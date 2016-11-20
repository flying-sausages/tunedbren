#!/bin/bash

name=$(basename $0)
filetypes="mp3 flac"

sanitize() {
	# Sanitizes file name components.
  # This will probably need to be extended to deal with exotic fuckery
  echo -n "$1" | sed -e 's| / |, |g' -e 's|/|,|g' -e 's|&|\\&|g' | tr -d '<>:"|?*\\'
}

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
			echo "${name}: Missing dependency: ${dep}" 1>&2
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
FILE_TEMPLATE='%n. %a - %s'
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
		-src) shift; SOURCE=$(echo ${1} | awk '{print toupper($0);}');
			;;
		*) IN_DIR="$1";
			;;
	esac
	shift;
done

# A few sanity checks...
[ -z "$IN_DIR" ] && { echo "${name}: No input directory."; usage; exit -2; }
[ -d "$IN_DIR" ] || { echo "${name}: '$IN_DIR' is not a directory."; exit -3; }
[ -z "$FILE_TEMPLATE" ] && { echo "${name}: No file template."; exit -3; }
[ -z "$DIR_TEMPLATE" ] && { echo "${name}: No directory template."; exit -3; }

# Convert ID3 tags if there are any MP3 files
[ $(ls "$IN_DIR" | grep -q '\.mp3$') ] && { 
	id3convert "$IN_DIR"/*.mp3 || {
		echo "${name}: Failed to convert ID3 tags, continuing anyway."
	}
}

for filetype in $filetypes
do
	ls "$IN_DIR"/*."$filetype" 2>/dev/null | while read IN_FILE
	do
		[ -n "$OUT_DIR" ] && {
			# If we have already moved the directory, adjust the input file name accordingly
			IN_FILE_BASE=$(basename "$IN_FILE")
			IN_FILE="${OUT_DIR}/${IN_FILE_BASE}"
		}

		# Grab info from meta tags
		case $filetype in
			mp3)
				TITLE=$(mp3info -p "%t" "$IN_FILE")
				TRACKNUMBER=$(mp3info -p "%n" "$IN_FILE")
				[ -z "$FILE_ARTIST" ] && { FILE_ARTIST=$(mp3info -p "%a" "$IN_FILE"); }
				[ -z "$DIR_ARTIST" ] && { DIR_ARTIST="$FILE_ARTIST"; }
				[ -z "$ALBUM" ] && { ALBUM=$(mp3info -p "%l" "$IN_FILE"); }
				[ -z "$YEAR" ] && { YEAR=$(mp3info -p "%y" "$IN_FILE"); }
				[ -z "$BITRATE" ] && { BITRATE=$(mp3info -p "%r" "$IN_FILE"); }
				;;
			flac)
				TITLE=$(flactag TITLE "$IN_FILE")
				TRACKNUMBER=$(flactag TRACKNUMBER "$IN_FILE")
				[ -z "$FILE_ARTIST" ] && { FILE_ARTIST=$(flactag ARTIST "$IN_FILE"); }
				[ -z "$DIR_ARTIST" ] && { DIR_ARTIST=$(flactag ALBUMARTIST "$IN_FILE"); }
				[ -z "$ALBUM" ] && { ALBUM=$(flactag ALBUM "$IN_FILE"); }
				[ -z "$YEAR" ] && { YEAR=$(flactag DATE "$IN_FILE"); }
				[ -z "$CATALOG" ] && { CATALOG=$(flactag CATALOGNUMBER "$IN_FILE"); }
				[ -z "$BITRATE" ] && { BITRATE="FLAC"; }
				;;
			*) echo "${name}: Unimplemented filetype $filetype"
				;;
		esac

		# Generate an output directory name, if there is none yet
		[ -z "$OUT_DIR" ] && {
			echo "Generating output directory name"
			[ -z "$DIR_ARTIST" ] && { echo "${name}: Empty directory artist. Please set it using the -a parameter."; exit -4; }
			[ -z "$ALBUM" ] && { echo "${name}: Empty Album field. Please set it using the -l parameter."; exit -4; }
			[ -z "$CATALOG" ] && { echo "${name}: Empty Catalogue Number field. Please set it using the -c parameter."; exit -4; }
			[ -z "$YEAR" ] && { echo "${name}: Empty Year field. Please set it using the -y parameter."; exit -4; }
			[ -z "$BITRATE" ] && { echo "${name}: Empty Bitrate field. Please set it using the -b parameter."; exit -4; }
			[ -z "$SOURCE" ] && { echo "${name}: Empty Source field. Please set it using the -src parameter."; exit -4; }

			# Eval directory template
			DIR_ARTIST=$(sanitize "$DIR_ARTIST")
			ALBUM=$(sanitize "$ALBUM")
			CATALOG=$(sanitize "$CATALOG")
			YEAR=$(sanitize "$YEAR")
			BITRATE=$(sanitize "$BITRATE")
			SOURCE=$(sanitize "$SOURCE")

			OUT_DIR=$(echo -n "$DIR_TEMPLATE" | sed -e "s/%a/${DIR_ARTIST}/g" -e "s/%l/${ALBUM}/g" -e "s/%c/${CATALOG}/g" -e "s/%y/${YEAR}/g" -e "s/%b/${BITRATE}/g" -e "s/%src/${SOURCE}/g" -e 's|%.|\&|g')
			OUT_DIR_PARENT=$(dirname "$IN_DIR")
			OUT_DIR="${OUT_DIR_PARENT}/${OUT_DIR}"
			mv "$IN_DIR" "$OUT_DIR"

			# Also, see if there's an image to be renamed
			[ -f "${OUT_DIR}/cover.jpg" -o -f "${OUT_DIR}/cover.png" ] || {
				find "$OUT_DIR" -maxdepth 1 -iname '*.jpg' | head -1 | while read newcover; do mv "$newcover" "${OUT_DIR}/cover.jpg"; done
				find "$OUT_DIR" -maxdepth 1 -iname '*.png' | head -1 | while read newcover; do mv "$newcover" "${OUT_DIR}/cover.png"; done
			}
		}

		[ -z "$TITLE" -o -z "$TRACKNUMBER" -o -z "$FILE_ARTIST" ] && {
			echo "${name}: Input file ${IN_FILE} does not contain required meta tags (artist, number and title)."
			exit -5
		}

		# Eval file template
		FILE_ARTIST=$(sanitize "$FILE_ARTIST")
		ALBUM=$(sanitize "$ALBUM")
		CATALOG=$(sanitize "$CATALOG")
		YEAR=$(sanitize "$YEAR")
		BITRATE=$(sanitize "$BITRATE")
		SOURCE=$(sanitize "$SOURCE")
		TITLE=$(sanitize "$TITLE")
		TRACKNUMBER=$(printf "%02d" "$TRACKNUMBER")
		TRACKNUMBER=$(sanitize "$TRACKNUMBER")

		OUT_FILE=$(echo -n "$FILE_TEMPLATE" | sed -e "s/%a/${FILE_ARTIST}/g" -e "s/%l/${ALBUM}/g" -e "s/%c/${CATALOG}/g" -e "s/%y/${YEAR}/g" -e "s/%b/${BITRATE}/g  " -e "s/%s/${TITLE}/g" -e "s/%src/${SOURCE}/g" -e "s/%n/${TRACKNUMBER}/g" -e 's|%.|\&|g')
		OUT_FILE="${OUT_FILE}.${filetype}"
		IN_FILE_BASE=$(basename "$IN_FILE")
		[ "${OUT_DIR}/${IN_FILE_BASE}" != "${OUT_DIR}/${OUT_FILE}" ] && mv "${OUT_DIR}/${IN_FILE_BASE}" "${OUT_DIR}/${OUT_FILE}"
	done
done

