# MSYS2 (UCRT64 / CLANG64) fish configuration.

fish_add_path --global \
    /c/Users/$USERNAME/.local/bin \
    /c/Users/$USERNAME/bin \
    '/c/Program Files/Git/cmd' \
    '/c/Program Files/TortoiseSVN/bin' \
    ~/tools/redis \
    '/c/Windows/System32/OpenSSH' \
    '/c/Program Files/xmake' \
    '/c/Program Files/CMake/bin' \
    '/c/Program Files/WSL/'

# Windows 侧 Store 版 PowerShell 7 只有 WindowsApps 里的执行别名（pwsh.exe）。
# 坑：fish_add_path 即使带 --append，也是写进 fish_user_paths，而 fish_user_paths
# 是整体前置到 $PATH 的，于是 WindowsApps 里那些 WSL 存根（bash.exe/arch.exe）
# 会抢在 MSYS2 自己的 /usr/bin 前面，`bash` 就被换成了 WSL 的 bash。
# 所以这里不走 fish_add_path，直接对 $PATH 做名副其实的尾部追加。
set -gx PATH $PATH /c/Users/$USERNAME/AppData/Local/Microsoft/WindowsApps

set -g fish_greeting ""

if status is-interactive
    fish_vi_key_bindings

    bind -M insert \ce forward-char
    # 用固定 ANSI 序列代替多次 `set_color` 子命令替换。
    # 在 MSYS2 下每次 `$(set_color ...)` 都会拉起一次子 shell / 管道求值，
    # 而每次按键切 Vi 模式（Esc / i / v / R）都会重跑 fish_mode_prompt + fish_prompt，
    # 原先合计 ~10 次命令替换会让切模式肉眼可见地卡一拍。
    function fish_mode_prompt --description "Vi mode indicator without command substitutions"
        switch $fish_bind_mode
            case default
                printf '\e[1;31m[N]\e[0m '
            case insert
                printf '\e[1;32m[I]\e[0m '
            case replace_one replace
                printf '\e[1;32m[R]\e[0m '
            case visual
                printf '\e[1;35m[V]\e[0m '
        end
    end

    function fish_prompt --description "Fast prompt for MSYS2 without set_color subshells"
        set -l last_status $status
        set -l prompt_symbol '>'
        if fish_is_root_user
            set prompt_symbol '#'
        end
        set -l status_prefix ''
        if test $last_status -ne 0
            set status_prefix \e"[31m[$last_status]"\e"[0m "
        end
        printf '\e[32m%s@%s\e[0m \e[33m%s\e[0m%s %s%s ' \
            "$USER" "$hostname" "$(prompt_pwd)" "$(fish_vcs_prompt)" "$status_prefix" "$prompt_symbol"
    end

    # 默认 fish_title 每次切模式也会跑一轮 `status current-command` + `prompt_pwd`；
    # 置空避免每次按 Esc/i 额外触发一次命令替换。
    function fish_title
    end
end

function __report_pwd_to_windows_terminal --on-variable PWD
    status is-interactive; or return
    type -q cygpath; or return
    set -l win_pwd (cygpath -w "$PWD" 2>/dev/null)
    if test -n "$win_pwd"
        printf '\e]9;9;"%s"\e\\' "$win_pwd"
    end
end
__report_pwd_to_windows_terminal

function ep
    explorer.exe (cygpath -w "$PWD")
end

function fish_vcs_prompt --description "Fast git branch prompt for MSYS2"
    set -l dir $PWD
    while test -n "$dir"
        if test -e "$dir/.git"
            set -l branch (command git symbolic-ref --short -q HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)
            test -n "$branch"; and printf ' (%s)' "$branch"
            return 0
        end
        set -l parent (string replace -r '/[^/]*$' '' -- $dir)
        test "$parent" = "$dir"; and break
        set dir $parent
    end
end

function nvide --description 'Start Neovide detached from fish job control'
    command neovide.exe $argv </dev/null >/dev/null 2>&1 &
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

# Change code page to UTF-8 (silently)
chcp.com 65001 > /dev/null
