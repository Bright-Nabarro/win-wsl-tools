# win-wsl-tools

Portable helpers and sanitized terminal dotfiles for a productive Windows + WSL2 + MSYS2 workflow.

## Tools

- `wslpath`: convert a Windows path to a WSL mount path.
- `msyspath`: convert a Windows path to an MSYS2 path.
- `upath`: convert a WSL path to a Windows path or WSL UNC path.
- `winpath`: convert an MSYS2 path to a Windows path.
- `wslhere`: open WSL2 in Windows Terminal at the current PowerShell directory.

- [`powershell-fish-vim`](./powershell-fish-vim/): portable PowerShell, fish, Windows Terminal, WezTerm and C/C++ tooling configuration.

## Deployment

Windows:

```powershell
.\install.ps1 -AddToPath
```

This copies `msyspath`, `wslpath`, and `wslhere` to `$HOME\bin`. With
`-AddToPath`, the installer also adds that directory to the user `PATH` when
needed. The operation is idempotent and can be run again after updating the
repository.

WSL:

```sh
./install-wsl.sh
```

This installs `upath` to `~/.local/bin`. Pass a directory as the first
argument to use a different destination.

MSYS2:

```sh
./install-msys2.sh
```

This installs `winpath` to `/usr/local/bin`, which is in the default MSYS2
`PATH`. Pass a directory as the first argument to use a different destination:

```sh
./install-msys2.sh ~/.local/bin
```

Restart your shell after adding a directory to `PATH`.

Verify the deployed commands:

```powershell
msyspath E:\workspace\config
```

```sh
winpath /e/workspace/config
```

## Usage

From Windows PowerShell:

```powershell
wslpath
# /mnt/c/Projects/demo

wslpath C:\Projects\demo
# /mnt/c/Projects/demo

msyspath E:\Projects\demo
# /e/Projects/demo

wslhere
# Opens a new Windows Terminal tab using a WSL profile at the current directory.
```

From WSL:

```sh
upath /mnt/c/Projects/demo
# C:\Projects\demo

upath -e /mnt/c/Projects/demo
# C:\\Projects\\demo

upath /home/user/project
# \\wsl.localhost\Ubuntu\home\user\project
```

From MSYS2:

```sh
winpath /e/Projects/demo
# E:\Projects\demo

winpath -e /e/Projects/demo
# E:\\Projects\\demo
```

## Configuration

`wslpath` and `upath` assume the WSL automount root is `/mnt`.

Override it when needed:

```powershell
$env:WSLPATH_MOUNT_ROOT = "/run/desktop/mnt/host"
```

```sh
export UPATH_MOUNT_ROOT=/mnt
```

`wslhere` tries to use an existing Windows Terminal WSL profile. Selection order:

1. `-Profile` argument or `WSLHERE_PROFILE` environment variable.
2. `-Distro` argument or `WSLHERE_DISTRO` environment variable.
3. Windows Terminal default profile, if it is a WSL profile.
4. First WSL-looking profile in Windows Terminal settings.
5. Plain `wsl.exe` fallback.

Examples:

```powershell
wslhere -Profile Ubuntu-24.04
wslhere -Distro Ubuntu-24.04
setx WSLHERE_PROFILE Ubuntu-24.04
```
