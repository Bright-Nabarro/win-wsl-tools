# WSL / Linux fish configuration.

fish_add_path ~/.local/bin

set -g fish_greeting ""

if status is-interactive
    fish_vi_key_bindings
    bind -M insert \ce forward-char
end

function __report_pwd_to_windows_terminal --on-variable PWD
    status is-interactive; or return
    type -q wslpath; or return
    set -l win_pwd (wslpath -w "$PWD" 2>/dev/null)
    if test -n "$win_pwd"
        printf '\e]9;9;"%s"\e\\' "$win_pwd"
    end
end
__report_pwd_to_windows_terminal

function ep
    explorer.exe .
end

function nvide --description 'Start Neovide detached from fish job control'
    command neovide.exe --wsl $argv </dev/null >/dev/null 2>&1 &
    disown
end

function cppc
    if type -q g++
        command g++ -g -std=c++23 $argv
    else
        command clang++ -g -std=c++23 $argv
    end
end

function ccc
    if type -q gcc
        command gcc -g -std=gnu23 $argv
    else
        command clang -g -std=gnu23 $argv
    end
end
