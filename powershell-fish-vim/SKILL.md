---
name: powershell-fish-vim
description: Configure PowerShell 7 in Windows Terminal with a fish-like Oh My Posh prompt, PSReadLine Vi editing, Python venv display, cursor restoration, and duplicate-tab current-directory inheritance.
---

# PowerShell Fish + Vim 配置说明

## 目标

这套配置让 PowerShell 7 在 Windows Terminal 中获得接近 fish + Vim 的交互体验，同时保持 PowerShell 原有的命令和对象管道能力。

最终效果：

```text
(project-venv) user@host  ~\work\project  (main *)
❯ command
```

- 第一行显示用户、主机、完整目录层级和 Git 状态。
- 输入光标独占第二行，避免长路径挤压命令区。
- Python venv 激活后，最左侧显示蓝色 `(环境名)`。
- 成功提示符为绿色；上一条命令失败时显示红色提示符和退出码。
- PSReadLine 使用 Vi 编辑模式。
- Windows Terminal 复制标签页时可继承当前 Profile 和文件系统目录。

## 环境与依赖

本配置制作和验证时使用：

- Windows Terminal `1.24.11321.0`
- PowerShell `7.6.3`
- PSReadLine `2.4.5`
- Oh My Posh `29.25.1`
- 字体：`Maple Mono NF CN`

主题没有依赖必须由 Nerd Font 才能显示的图标，因此换用普通等宽字体也能工作。若使用仓库中的 Windows Terminal 片段，则需要提前安装 `Maple Mono NF CN`，或者把字体名称替换为自己的字体。

## 目录结构

```text
powershell-fish-vim/
├── README.md
├── SKILL.md
├── configs/
│   ├── Microsoft.PowerShell_profile.ps1
│   ├── fish-vim.omp.json
│   └── windows-terminal.fragment.jsonc
└── scripts/
    └── install.ps1
```

## 安装

### 1. 安装 Oh My Posh

```powershell
winget install --id JanDeDobbeleer.OhMyPosh --exact
```

安装后确认：

```powershell
oh-my-posh version
```

### 2. 安装配置文件

在本目录中运行：

```powershell
pwsh -File .\scripts\install.ps1
```

脚本会：

1. 检查当前是否为 PowerShell 7。
2. 确认 Oh My Posh 可执行文件存在。
3. 创建当前用户的 PowerShell Profile 目录。
4. 给现有 Profile 和主题添加带时间戳的 `.backup-*` 备份。
5. 将 Profile 与主题复制到 Profile 所在目录。
6. 解析 Profile 并调用 Oh My Posh 渲染主题，验证配置可用。

默认目标位置：

```text
%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
%USERPROFILE%\Documents\PowerShell\fish-vim.omp.json
```

### 3. 合并 Windows Terminal 设置

打开 Windows Terminal 的 `settings.json`，参考 `configs/windows-terminal.fragment.jsonc` 合并：

- PowerShell Profile 使用 `emptyBox` 光标。
- 使用 `Maple Mono NF CN` 字体。
- `Ctrl+Shift+A` 绑定 `duplicateTab`。

不要直接使用片段覆盖完整 `settings.json`，因为其中可能已有其他 Profile、快捷键、背景图片和配色。

### 4. 重新加载

重新打开 Windows Terminal，或者执行：

```powershell
. $PROFILE
```

## 配置详解

### Oh My Posh 外观

`fish-vim.omp.json` 使用双 Prompt Block：

- 第一块：Python venv、会话、路径、Git。
- 第二块设置 `newline: true`，只显示输入符号。

路径使用 `style: full`，保留全部目录层级；用户主目录仍按 shell 习惯显示为 `~`。

Git 段显示：

- 当前分支。
- 工作区有修改时显示 `*`。
- 相对上游的 ahead/behind 数量。

### Python venv

Python 段配置为：

```json
{
  "display_mode": "environment",
  "fetch_virtual_env": true,
  "fetch_version": false
}
```

因此：

- 未激活 venv 时完全隐藏。
- 激活 venv 后显示蓝色 `(venv-name)`。
- 不查询 Python 版本，减少提示符开销。
- 执行 `deactivate` 后自动消失。

### Vi 模式

Profile 使用：

```powershell
Set-PSReadLineOption -EditMode Vi
```

基本操作：

- `Esc`：进入 Command/Normal 模式。
- `i`、`a`：回到 Insert 模式。
- Command 模式使用 PSReadLine 的 Vi 移动、删除和修改操作。

Insert 模式额外保留：

| 按键 | 功能 |
| --- | --- |
| `Ctrl+A` | 移到行首 |
| `Ctrl+E` | 移到行尾 |
| `Ctrl+W` | 删除前一个单词 |
| `Ctrl+U` | 删除光标前内容 |
| `Ctrl+K` | 删除光标后内容 |
| `Ctrl+R` | 反向搜索历史 |
| `Ctrl+P/N` | 上/下一条历史 |
| `Ctrl+L` | 清屏 |
| `Tab` | 菜单补全 |
| `↑/↓` | 按当前输入前缀搜索历史 |

### Vi 光标修复

PSReadLine 内置的 `ViModeIndicator Cursor` 会在从 Normal 返回 Insert 后强制使用下划线光标，覆盖 Windows Terminal 的 `cursorShape`。

最终配置改用脚本模式：

- Command/Normal：发送 `ESC [ 2 SP q`，使用稳定的实心块。
- Insert：发送 `ESC [ 0 SP q`，恢复终端默认光标，因此重新使用 Windows Terminal 中配置的 `emptyBox`。

### fish 风格历史预测

交互式且支持 VT 的终端会启用：

```powershell
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView
```

在输出被重定向、CI 或非交互运行中不会启用预测，避免 PSReadLine 启动报错。

其他历史设置：

- 不保存连续重复历史。
- 前缀历史搜索后把光标移到行尾。
- 最大历史数量 `10000`。
- 关闭响铃。

### Windows Terminal 当前目录继承

Windows Terminal 的 `duplicateTab` 只能在 shell 主动报告当前目录后正确继承目录。

最终方案使用 Oh My Posh 原生设置：

```json
"pwd": "osc99"
```

Oh My Posh 会在提示符中发送 `OSC 9;9` 当前目录通知。Windows Terminal 收到后，`Ctrl+Shift+A` 的 `duplicateTab` 会复制当前 Terminal Profile 和目录。

限制：Windows Terminal 会启动一个新的 PowerShell 进程，因此不会克隆当前进程中的临时状态，例如：

- 已激活 venv 的环境变量。
- 当前 PowerShell 变量。
- 未持久化的别名或函数。
- 当前命令行中尚未执行的文本。

### 小工具

Profile 还增加了：

```powershell
which pwsh
mkcd path\to\new-directory
```

`which` 映射到 `Get-Command`；`mkcd` 会创建目录并立即进入。

## 修改过程与最终决策

### 初始配置

1. 检查 PowerShell、Profile、PSReadLine 和 Oh My Posh 状态。
2. 通过 winget 安装 Oh My Posh `29.25.1`。
3. 创建双行主题和 PowerShell Profile。
4. 启用 Vi 模式、历史预测、菜单补全与快捷键。
5. 增加非交互环境检查，解决重定向输出时无法启用预测的错误。

### 光标修复

1. 读取 Windows Terminal 的 PowerShell Profile，确认 `cursorShape` 为 `emptyBox`。
2. 将 `ViModeIndicator Cursor` 改为 `ViModeIndicator Script`。
3. Normal 使用实心块，Insert 使用“恢复 Terminal 默认值”的控制序列。

### venv 提示

1. 添加 Oh My Posh Python 段。
2. 仅在虚拟环境中显示。
3. 使用蓝色 `#61AFEF`。
4. 关闭 Python 版本查询。

### 复制标签页目录

第一次实现使用 PowerShell `prompt` 包装函数手动发送 `OSC 9;9`。控制序列验证正确，但实际 Windows Terminal 仍打开默认目录。

该方案已经撤销。最终改用 Oh My Posh 自带的 `pwd: osc99`，让目录通知由生成提示符的同一组件负责，避免提示符包装与 Oh My Posh 生命周期冲突。

### 本机备份记录

配置过程中保留了以下类型的备份：

```text
Microsoft.PowerShell_profile.ps1.backup-cursor-20260711-170347
fish-vim.omp.json.backup-venv-20260711-170723
Microsoft.PowerShell_profile.ps1.backup-cwd-20260711-171114
Microsoft.PowerShell_profile.ps1.backup-native-cwd-20260711-171647
fish-vim.omp.json.backup-native-cwd-20260711-171647
```

新安装脚本也会继续使用 `.backup-yyyyMMdd-HHmmss` 命名方式。

## 验证

### Profile 语法

```powershell
$text = Get-Content $PROFILE -Raw
[void][scriptblock]::Create($text)
```

### PSReadLine

```powershell
Get-PSReadLineOption |
    Select-Object EditMode, ViModeIndicator, PredictionSource,
        BellStyle, HistoryNoDuplicates, HistorySearchCursorMovesToEnd
```

预期：

- `EditMode` 为 `Vi`。
- `ViModeIndicator` 为 `Script`。
- 交互式 Windows Terminal 中 `PredictionSource` 为 `History`。

### Oh My Posh

```powershell
oh-my-posh print primary --config "$HOME\Documents\PowerShell\fish-vim.omp.json"
```

### venv

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
deactivate
```

激活后应显示蓝色环境名；退出后应消失。

### 当前目录复制

```powershell
cd C:\some\test\directory
```

等待新提示符绘制后按 `Ctrl+Shift+A`。新标签页应使用相同 PowerShell Profile，并从测试目录启动。

## 故障排查

### Oh My Posh 未显示

```powershell
Get-Command oh-my-posh
Test-Path "$HOME\Documents\PowerShell\fish-vim.omp.json"
```

确认 `$PROFILE` 与主题位于同一目录。

### venv 不显示

```powershell
$env:VIRTUAL_ENV
```

变量为空表示虚拟环境没有正确激活。

### 新标签页仍进入默认目录

1. 确认完全关闭并重新启动 Windows Terminal。
2. 确认主题包含 `"pwd": "osc99"`。
3. 确认快捷键实际调用 `duplicateTab`，不是普通 `newTab`。
4. 切换目录后等待提示符重新绘制，再复制标签页。

### Ctrl+A 冲突

字面意义的 `Ctrl+A` 保留给 PSReadLine 的“移动到行首”。Windows Terminal 复制标签页使用 `Ctrl+Shift+A`。

## 参考资料

- Oh My Posh 一般配置与 `pwd`：https://ohmyposh.dev/docs/configuration/general
- Oh My Posh Python 段：https://ohmyposh.dev/docs/segments/languages/python
- Oh My Posh Path 段：https://ohmyposh.dev/docs/segments/system/path
- Windows Terminal 同目录标签页：https://learn.microsoft.com/windows/terminal/tutorials/new-tab-same-directory
- Windows Terminal Actions：https://learn.microsoft.com/windows/terminal/customize-settings/actions
- PSReadLine：https://learn.microsoft.com/powershell/module/psreadline/
