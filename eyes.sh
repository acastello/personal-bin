#!/bin/bash

[[ 2 = "$(dunstify --action=ignore,ignore Eyes!)" ]] && {
    sleep 0.75
    xset dpms force off
    sleep 20.75
    xset dpms force on
}
