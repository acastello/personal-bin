#!/bin/bash

set -eu

[[ -f "$1" ]]
in="$1"
target="$2"

shift 2

if [ $# -gt 0 ]; then
    args=("$@")
else
    args=("-l" "html2")
fi

DIR="$(mktemp -d)"

trap "rm -rf \"$DIR\"" EXIT

swagger-codegen generate -i "$in" "${args[@]}" -o "$DIR"
mv -fv "$DIR/index.html" "$target"

