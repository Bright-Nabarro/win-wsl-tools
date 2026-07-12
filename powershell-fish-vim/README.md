# Portable Terminal Dotfiles

一套经过隐私清理的 Windows + WSL 终端开发环境配置。核心体验来自 PowerShell 7、Oh My Posh、PSReadLine Vi 模式和 fish，同时整合 Windows Terminal、WezTerm、clangd 与 clang-format 的可移植设置。

主要功能：

- 双行 fish 风格 PowerShell 提示符，支持 Git、命令状态和 Python venv。
- PowerShell/fish Vi 键位、历史预测和菜单补全。
- Vi Normal/Insert 光标切换后恢复终端预设形状。
- Windows Terminal/WezTerm 新标签页继承当前目录。
- Windows Terminal 当前外观、Adventure 配色和有效快捷键的去标识化快照。
- C23/C++23 编译助手、clangd 与 clang-format 通用配置。

完整的设计说明、变更记录、隐私处理、安装步骤与故障排查见 [SKILL.md](./SKILL.md)。

## 快速安装

PowerShell：

```powershell
winget install --id JanDeDobbeleer.OhMyPosh --exact
pwsh -File .\scripts\install.ps1
```

WSL/Linux 配置按需安装，不会修改默认 shell：

```bash
./scripts/install-wsl.sh --fish --clang
# 可选：再加 --wezterm
```

Windows Terminal：

- `configs/windows-terminal/settings.portable.jsonc` 是当前设置的去标识化可移植快照。
- `configs/windows-terminal.fragment.jsonc` 是最小合并片段。
- 两者都不会设置系统默认终端，也不包含 `defaultProfile`。
- 请手动合并，不要直接覆盖自己的完整 `settings.json`。

## 文件

- `configs/Microsoft.PowerShell_profile.ps1`：PowerShell、PSReadLine 和 Vi 配置。
- `configs/fish-vim.omp.json`：Oh My Posh 主题。
- `configs/fish/config.fish`：去除代理、设备地址和个人路径后的 fish 配置。
- `configs/wezterm/wezterm.lua`：可移植 WezTerm 外观与键位。
- `configs/dev/.clangd`、`.clang-format`：C/C++ 开发配置。
- `configs/windows-terminal/`：Windows Terminal 最小片段和去标识化快照。
- `scripts/install.ps1`：带备份的 PowerShell 安装脚本。
- `scripts/install-wsl.sh`：显式选择组件、带备份且不修改默认 shell的 WSL/Linux 安装脚本。
- `SKILL.md`：完整说明和变更记录。
