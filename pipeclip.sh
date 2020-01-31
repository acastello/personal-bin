#!/bin/bash

function mpv-clip() {
    vid="${1:?}"
    if [[ "$vid" = *[?\&]t=* ]]; then
        t="${vid##*t=}"
        t="${t%%s*}"
        # t="${t%%\&*}"
        if [[ "$vid" = *watch* ]]; then
            vid="${vid%%\&*}"
        else
            vid="${vid%%\?*}"
        fi
    fi

    mpv "$vid" ${t:+--start="$t"} ${@:1}
}

link="$(xclip -o selection clipboard)"

if [ $# -gt 0 ]; then
    ${1##\#*:} "${link%%&list=*}" &>/dev/null &

    elif [[ "$link" = *youtu*be* ]]; then

        echo "#1 ↓ podcast: youtube-dl --format 140 -o ~/podcasts/%(title)s-%(id)s.%(ext)s"
        echo "#2 ↓ music:   youtube-dl --format 140 -o ~/music/%(title)s-%(id)s.%(ext)s"
        echo "#3 ↓ video:   youtube-dl -o ~/Videos/%(title)s-%(id)s.%(ext)s"
        echo "#4 ● watch:   mpv-clip"
        echo "#5 ● watch:   mpv-clip --title=_floating_wildcard --autofit=40% --geometry=-0+0 --ytdl-format=worst"
        echo "#6 ● cast:    catt cast"
        echo "#7 ● cast:    catt add"

    else

        echo "#1 ↓ podcast: wget -P ~/podcasts/"
fi


# vim: tw=0
