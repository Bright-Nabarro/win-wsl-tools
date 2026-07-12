#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="${HOME}/.terminal-dotfiles-backup-${STAMP}"

install_fish=false
install_wezterm=false
install_clang=false

usage() {
    cat <<'EOF'
Usage: ./scripts/install-wsl.sh [--fish] [--wezterm] [--clang] [--all]

Installs only explicitly selected user-level configuration.
It does not run chsh, modify /etc/shells, set a default terminal, or configure proxies.
EOF
}

while (($#)); do
    case "$1" in
        --fish) install_fish=true ;;
        --wezterm) install_wezterm=true ;;
        --clang) install_clang=true ;;
        --all)
            install_fish=true
            install_wezterm=true
            install_clang=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

if ! $install_fish && ! $install_wezterm && ! $install_clang; then
    usage
    exit 2
fi

backup_and_link() {
    local source=$1
    local target=$2

    mkdir -p "$(dirname -- "$target")"
    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv -- "$target" "$BACKUP_DIR/$(basename -- "$target")"
    fi
    ln -s -- "$source" "$target"
    printf 'Linked %s -> %s\n' "$target" "$source"
}

if $install_fish; then
    command -v fish >/dev/null || {
        echo 'fish is not installed; skipping fish config.' >&2
        exit 1
    }
    backup_and_link "$ROOT_DIR/configs/fish/config.fish" "$HOME/.config/fish/config.fish"
fi

if $install_wezterm; then
    backup_and_link "$ROOT_DIR/configs/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
fi

if $install_clang; then
    backup_and_link "$ROOT_DIR/configs/dev/.clangd" "$HOME/.clangd"
    backup_and_link "$ROOT_DIR/configs/dev/.clang-format" "$HOME/.clang-format"
fi

if [[ -d "$BACKUP_DIR" ]]; then
    printf 'Backups: %s\n' "$BACKUP_DIR"
fi
