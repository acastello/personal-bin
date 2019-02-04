#!/bin/sh

CHARS=( '\ ' 
        ' \' 
        ' /' 
        '/ ' )
I=0

while read -r line || [ -n "$line" ] ; do
    echo -e "\e[1m${CHARS[$I]} \e[21m $line"
    I=$((($I + 1) % ${#CHARS[@]}))
done
