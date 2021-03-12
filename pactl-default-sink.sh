#!/bin/bash

sink=${1:-1}
pactl list short sinks  \
  | awk "FNR == $sink"'{print $1}'  \
  | while read sinkn; do
    pactl set-default-sink $sinkn
  done
