# PowerShell Fish + Vim

一套面向 Windows Terminal 和 PowerShell 7 的 fish 风格配置：双行 Oh My Posh 提示符、PSReadLine Vi 模式、历史预测、Python venv 标识，以及复制标签页时继承当前目录。

完整的设计说明、变更记录、安装步骤与故障排查见 [SKILL.md](./SKILL.md)。

## 快速安装

```powershell
winget install --id JanDeDobbeleer.OhMyPosh --exact
pwsh -File .\scripts\install.ps1
```

安装脚本会备份现有 PowerShell Profile 和同名 Oh My Posh 主题，但不会自动覆盖 Windows Terminal 的完整 `settings.json`。Terminal 设置请按 [windows-terminal.fragment.jsonc](./configs/windows-terminal.fragment.jsonc) 手动合并。

## 文件

- `configs/Microsoft.PowerShell_profile.ps1`：PowerShell、PSReadLine 和 Vi 配置。
- `configs/fish-vim.omp.json`：Oh My Posh 主题。
- `configs/windows-terminal.fragment.jsonc`：Windows Terminal 配置片段。
- `scripts/install.ps1`：带备份的安装脚本。
- `SKILL.md`：完整说明和变更记录。
