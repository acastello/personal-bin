#!/bin/sh

ghci=ghci
which ghci 2>/dev/null ||
    ghci="stack ghci"

prog="$ghci ${1:-$HOME/.local/share/Math.hs}"

st -T _floating_wildcard -e vim-term "$prog"
