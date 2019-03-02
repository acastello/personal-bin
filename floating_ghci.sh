#!/bin/sh

prog="ghci ${1:-~/.local/share/Math.hs}"

floating_urxvt -e vim-term "$prog"
