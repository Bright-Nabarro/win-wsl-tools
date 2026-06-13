# win-wsl-tools

Tiny path helpers for moving between Windows PowerShell and WSL2.

## Tools

- `wpath`: convert a Windows path to a WSL mount path.
- `upath`: convert a WSL path to a Windows path or WSL UNC path.
- `wslhere`: open WSL2 in Windows Terminal at the current PowerShell directory.

## Install

Windows:

```powershell
.\install.ps1 -AddToPath
```

WSL:

```sh
./install-wsl.sh
```

Restart your shell after adding a directory to `PATH`.

## Usage

From Windows PowerShell:

```powershell
wpath
# /mnt/c/Projects/demo

wpath C:\Projects\demo
# /mnt/c/Projects/demo

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

## Configuration

`wpath` and `upath` assume the WSL automount root is `/mnt`.

Override it when needed:

```powershell
$env:WPATH_MOUNT_ROOT = "/run/desktop/mnt/host"
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
