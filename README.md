Renames mp3 and flac files and directories according to their tags.

This script requires properly tagged files. As a rule of thumb, the following tags should always be considered required:
  artist, title, track number.

This script relies on the following dependencies, please make sure you've got them installed
> id3convert (id3lib-tools) mp3info metaflac egrep cut awk sed

You can specify any missing fields (and/or override the tags) using the options below.

OPTIONS

>  -t 'file-template':
>    Rename files according to this template. The appropriate suffix is automatically attached to the rendered template. The default is '%n. %a - %s'

>  -d 'dir-template':
>    Set the output directory template. The default is '%a - %l [%c] [%y] [%src] [%b]'
>
>  -a 'artist':
>    Set the Artist field that will be used for dir-template.
>
>  -ta 'artist':
>    Set the Artist field that will be used for file-template.
>
>  -l 'album':
>    Set the Album field.
>
>  -c 'cataloguenumber':
>    Set the Catalogue Number field.
>
>  -y 'year':
>    Set the Year field.
>
>  -b 'bitrate':
>    Set the Bitrate field. (you MUST set this with VBR MP3s, e.g. V0)
>
>  -src 'source':
>    Set the Source field.

TEMPLATES

  Templates are a string containing an arbitrary number of special sequences such as %this.
  The supported sequences are:

    %a - Artist
    %l - Album
    %s - Song Title
    %n - Track Number
    %c - Catalogue Number
    %y - Year
    %b - Bitrate
    %src - Source
