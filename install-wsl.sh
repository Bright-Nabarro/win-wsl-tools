#!/usr/bin/env sh
set -eu

install_dir=${1:-"$HOME/.local/bin"}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

mkdir -p "$install_dir"
cp "$script_dir/bin/upath" "$install_dir/upath"
chmod +x "$install_dir/upath"

printf 'Installed WSL tools to %s\n' "$install_dir"
