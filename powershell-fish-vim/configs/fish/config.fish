# Portable fish configuration for interactive WSL/Linux sessions.

fish_add_path ~/.local/bin
set fish_greeting ""

if status is-interactive
    fish_vi_key_bindings

    # Accept the current autosuggestion while remaining in Insert mode.
    bind -M insert \ce forward-char
end

# Let Windows Terminal duplicate tabs and panes in the current WSL directory.
function __report_pwd_to_windows_terminal --on-variable PWD
    if test -n "$WT_SESSION"; and type -q wslpath
        printf "\e]9;9;%s\e\\" (wslpath -w "$PWD")
    end
end
__report_pwd_to_windows_terminal

# Open the current WSL directory in Windows Explorer.
function explorer_here
    if type -q explorer.exe
        explorer.exe .
    else
        echo "explorer.exe is unavailable" >&2
        return 127
    end
end

# Start Neovide connected to WSL when the Windows executable is available.
function nvide
    if type -q neovide.exe
        nohup neovide.exe --wsl $argv >/dev/null 2>&1 &
    else
        echo "neovide.exe is unavailable" >&2
        return 127
    end
end

function cppc
    command g++ -g -std=c++23 $argv
end

function ccc
    command gcc -g -std=gnu23 $argv
end
