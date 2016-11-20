Renames mp3 and flac files and directories according to DB9 standards.

This script requires properly tagged files. As a rule of thumb, the following tags should always be considered required:
  artist, title, track number.

You can specify any missing fields (and/or override the tags) using the options below.

OPTIONS

>  -t 'file-template':
>    Rename files according to this template. The appropriate suffix is automatically attached to the rendered template. The default is '0%n. %a - %s'

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
