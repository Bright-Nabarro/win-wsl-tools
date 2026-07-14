#!/usr/bin/env sh
set -eu

install_dir=${1:-/usr/local/bin}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

mkdir -p "$install_dir"
cp "$script_dir/bin/winpath" "$install_dir/winpath"
chmod +x "$install_dir/winpath"

printf 'Installed MSYS2 tools to %s\n' "$install_dir"
