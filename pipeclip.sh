#!/bin/bash

if [ $# -gt 0 ]; then

    ${1##\#*:} "$(xclip -o -selection clipboard)" &>/dev/null &

else

    echo "#1 podcast: youtube-dl --format 140 -o ~/podcasts/%(title)s-%(id)s.%(ext)s"
    echo "#2 music:   youtube-dl --format 140 -o ~/music/%(title)s-%(id)s.%(ext)s"
    echo "#3 video:   youtube-dl --format -o ~/Videos/%(title)s-%(id)s.%(ext)s"

fi


# vim: tw=0
