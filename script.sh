if [[ $# -eq 0 ]] ; then
    echo 'You gotta give me some directory to work with, mate.\n Use me like so: \"db9names /home/you/folder.with.mp3s/\"'
    exit 0
fi

dir=$1


echo "Wanna check and possibly edit the tags before we move all this shit? [N/y]"

# Read out the tags from all files

# Ask if it looks good

# Specify track numbers to edit the tags for
# If not track tags then just edit all of them

#Rename to DB9 standards
id3ren -template='%n. %a - %s.mp3' "$dir"/*.mp3

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

echo "Moving to new dir = ${newdir}
mv "$dir" "${newdir}"
