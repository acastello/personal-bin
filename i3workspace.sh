#!/bin/sh

if [ $# -gt 0 ]; then
    i3-msg workspace "$1" >/dev/null
else
    i3-msg -t get_workspaces | jq '.[] | .name' -r
fi

# i3-msg workspace "$(cat)"
