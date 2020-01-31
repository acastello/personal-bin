#/bin/bash

set -eu

delay="$1"
shift
processes="$@"

kill -19 ${processes[@]}
trap "kill -18 ${processes[@]}" EXIT
sleep "$delay"
