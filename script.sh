if [[ $# -eq 0 ]] ; then
    echo 'You gotta give me some directory to work with, mate.\n Use me like so: \"db9names /home/you/folder.with.mp3s/\"'
    exit 0
fi

dir=$1

#Should ask what standard to use for renaming
    #Or make one quickly on the fly, and allow to save it and reuse

# make sure to convert all the tags first
id3converet "$dir"/.mp3

echo "Wanna check and possibly edit the tags before we move all this shit? [N/y]"
# If yes, read out song nr, track, artist, album and year into stdout
# Ask if correct
    # if not, ask for track numbers to edit or leave blank to edit the entire thing
            #maybe wipe all tags? Ask which ones should remain?
            #Ask which fields áre the same for all files
            #Apply all common tags
            #Have user fill out the remaining tags one by one


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
