#!/bin/sh

set -eu

[[ -f "$1" ]]

DIR="$(mktemp -d)"

trap "rm -rf \"$DIR\"" EXIT

swagger-codegen generate -i "$1" -l html2 -o "$DIR"
mv -fv "$DIR/index.html" "$2"

