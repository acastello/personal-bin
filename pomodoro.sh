#!/bin/bash

initial_delay=${1:-0}

sleep "$initial_delay"

while :; do
    notify-send -i view-refresh "Πομοδορο" "[$(date "+%H:%M")] back to work"
    sleep $((25 * 60))
    notify-send -t 298000 -i process-stop "Πομοδορο" "[$(date "+%H:%M")] 5 minute break"
    sleep $((5 * 60))
done
