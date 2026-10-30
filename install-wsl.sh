#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
TARGET_DIR="$HOME/.local/bin"
install_fish=0
install_tmux=0
install_clang=0

for arg in "$@"; do
    case "$arg" in
        --fish)  install_fish=1 ;;
        --tmux)  install_tmux=1 ;;
        --clang) install_clang=1 ;;
        --all)   install_fish=1; install_tmux=1; install_clang=1 ;;
        *)       TARGET_DIR=$arg ;;
    esac
done

mkdir -p "$TARGET_DIR"
cp "$SCRIPT_DIR/bin/upath" "$TARGET_DIR/upath"
chmod +x "$TARGET_DIR/upath"
printf 'Installed upath -> %s/upath\n' "$TARGET_DIR"

if [ "$install_fish" -eq 1 ]; then
    mkdir -p "$HOME/.config/fish"
    cp "$SCRIPT_DIR/configs/wsl/config.fish" "$HOME/.config/fish/config.fish"
    printf 'Installed WSL fish config -> %s/.config/fish/config.fish\n' "$HOME"
fi

if [ "$install_tmux" -eq 1 ]; then
    cp "$SCRIPT_DIR/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"
    printf 'Installed tmux config -> %s/.tmux.conf\n' "$HOME"
fi

if [ "$install_clang" -eq 1 ]; then
    cp "$SCRIPT_DIR/configs/dev/.clangd" "$HOME/.clangd"
    cp "$SCRIPT_DIR/configs/dev/.clang-format" "$HOME/.clang-format"
    printf 'Installed clang configs -> %s\n' "$HOME"
fi
