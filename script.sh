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
	cat << EOF
Renames mp3 and flac files and directories according to DB9 standards.

This script requires properly tagged files. As a rule of thumb, the following tags should always be considered required:
	artist, title, track number.

You can specify any missing fields (and/or override the tags) using the options below.

OPTIONS:
	-t 'file-template'
		Rename files according to this template. The appropriate suffix is automatically attached to the rendered template. The default is '0%n. %a - %s'
	-d 'dir-template'
		Set the output directory template. The default is '%a - %l (%src %b) [%c %y]'
	-a 'artist'
		Set the Artist field that will be used for dir-template.
	-ta 'artist'
		Set the Artist field that will be used for file-template.
	-c 'cataloguenumber'
		Set the Catalogue Number field.
	-y 'year'
		Set the Year field.
	-b 'bitrate'
		Set the Bitrate field.
	-src 'source'
		Set the Source field.

TEMPLATES
	Templates are a string containing an arbitrary number of special sequences such as %this.
	The supported sequences are:

		%a - Artist
		%l - Album
		%s - Song
		%n - Track Number
		%c - Catalogue Number
		%y - Year
		%b - Bitrate
		%src - Source
		
EOF
	exit -1
}

[[ $# -lt 1 ]] && usage

dir=$1


id3convert "$dir"/*.mp3 || {
	echo " failed"
}

#Should ask what standard to use for renaming
    #Or make one quickly on the fly, and allow to save it and reuse

# make sure to convert all the tags first
id3convert "$dir"/.mp3

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
mv "$dir" "${newdir}"
