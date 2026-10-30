# win-wsl-tools

Windows、MSYS2（默认 `UCRT64`）与 WSL2 跨环境路径转换工具及终端配置集。

## 目录结构

```text
├── bin/
│   ├── msyspath.{ps1,cmd}   # Windows -> MSYS2 路径转换 (C:\foo -> /c/foo)
│   ├── wslpath.{ps1,cmd}    # Windows -> WSL 路径转换 (C:\foo -> /mnt/c/foo)
│   ├── wslhere.{ps1,cmd}    # 在当前目录打开 Windows Terminal WSL 标签页
│   ├── winpath              # MSYS2 -> Windows 路径转换 (/c/foo -> C:\foo)
│   └── upath                # WSL -> Windows 路径转换 (/mnt/c/foo -> C:\foo)
├── configs/
│   ├── msys2/
│   │   ├── config.fish          # MSYS2 (UCRT64/CLANG64) Fish 配置（极速 Vi 模式提示符、OSC 9;9）
│   │   └── functions/wrun.fish  # 使用纯净 Windows 注册表 PATH 运行命令或进入 pwsh
│   ├── wsl/config.fish          # WSL Fish 配置
│   ├── powershell/
│   │   ├── Microsoft.PowerShell_profile.ps1  # PowerShell 7 Vi 模式 + PSReadLine 配置
│   │   └── fish-vim.omp.json                 # Oh My Posh 主题
│   ├── tmux/.tmux.conf          # tmux 配置（OSC 52 剪贴板、fish 默认 shell、窗口快捷键）
│   ├── dev/{.clangd,.clang-format}
│   └── windows-terminal/settings.portable.jsonc  # Windows Terminal 配置模板（默认 MSYS2 ucrt64）
├── install.ps1
├── install-msys2.sh
└── install-wsl.sh
```

## 快速安装

### Windows (PowerShell)

```powershell
# 仅安装命令工具 (msyspath / wslpath / wslhere) 到 ~/bin
.\install.ps1 -AddToPath

# 同时安装命令工具与 PowerShell Profile 配置
.\install.ps1 -All
```

### MSYS2 (UCRT64 / CLANG64)

```sh
# 仅安装 winpath 到 /usr/local/bin
./install-msys2.sh

# 安装 winpath + fish 配置 (含 wrun) + tmux + clang 配置
./install-msys2.sh --all
```

### WSL2

```sh
# 仅安装 upath 到 ~/.local/bin
./install-wsl.sh

# 安装 upath + fish + tmux + clang 配置
./install-wsl.sh --all
```

## 常用命令与函数

| 环境 | 命令 | 说明 |
| --- | --- | --- |
| Windows | `msyspath [PATH]` | 将当前目录或指定路径转为 MSYS2 路径（如 `/c/Users/...`） |
| Windows | `wslpath [PATH]` | 将当前目录或指定路径转为 WSL 挂载路径（如 `/mnt/c/Users/...`） |
| Windows | `wslhere [PATH]` | 在 Windows Terminal 中打开对应目录的 WSL2 标签页 |
| MSYS2 | `winpath [-e] [PATH]` | 将 MSYS2 路径转为 Windows 路径（`-e` 输出双反斜杠转义） |
| MSYS2 | `wrun [cmd args...]` | 使用纯净 Windows 注册表 `Path` 执行命令/批处理；无参数时启动交互式 `pwsh` |
| WSL2 | `upath [-e] [PATH]` | 将 WSL 路径转为 Windows 路径或 `\\wsl.localhost\...` UNC 路径 |
| Fish / PWSH | `ep` | 在资源管理器中打开当前目录 |
| Fish | `cppc` / `ccc` | 使用 `g++`/`gcc`（或回退 `clang++`/`clang`）以 C++23 / C23 标准带调试符号编译 |
