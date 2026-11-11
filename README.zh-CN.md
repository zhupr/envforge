# envforge

[English](README.md) · **简体中文**

一条命令部署开发环境，支持 **macOS**、**Linux**、**Docker**。覆盖 Zsh、Neovim
(LazyVim)、tmux、Herdr、omp、C++/Python/Go/Rust 工具链以及一组现代 CLI 工具。
在线、公司镜像、完全离线三种场景都可用。

```bash
git clone https://github.com/<you>/envforge.git ~/code/envforge
cd ~/code/envforge
./install.sh                # 安装全部
./install.sh --zsh --nvim   # 或只装需要的
./install.sh --interactive  # 菜单勾选组件
```

## 安装内容

| 组件 | macOS | Linux | 配置文件 |
|---|---|---|---|
| **Zsh** | zsh + zimfw + powerlevel10k | 同左 | `.zshrc`, `.zimrc` |
| **Neovim** | neovim | AppImage 或 tarball | LazyVim + TokyoNight，`blink.cmp` |
| **tmux** | tmux + gpakosz | 同左 | `tmux.conf.local` |
| **Herdr** | brew / 安装脚本 | 安装脚本 | `~/.config/herdr/config.toml` |
| **omp** | 安装脚本 | 安装脚本 | `~/.omp/agent/config.yml` |
| **C++** | cmake + llvm | cmake + clang | clangd、clang-format、vcpkg |
| **Python** | miniconda | miniconda | ruff、pyright |
| **Go** | go | tarball | gopls、delve、staticcheck |
| **Rust** | rustup | rustup | rust-analyzer |
| **Node.js** | nvm | nvm / tarball | LTS |
| **CLI 工具** | eza、bat、ripgrep、fzf、fd、yazi、lazygit、tree、htop、jq、wget、glow | 同左 | 别名在 `.zshrc` |
| **Nerd Font** | Meslo LG L | Meslo LG L | 需在终端里设置字体 |

启用的 LazyVim extras 包括 `editor.fzf`、`editor.harpoon2`、`lang.markdown`、
`lang.python`、`lang.rust`、`lang.typescript`、`lang.yaml`、`linting.eslint`、
`formatting.prettier`、`util.project` 等，详见 `config/nvim/lazyvim.json`。

## 安装选项

```bash
./install.sh --all          # 全部（无参数时默认）
./install.sh --zsh          # Zsh + zimfw + powerlevel10k
./install.sh --nvim         # Neovim + LazyVim
./install.sh --tmux         # tmux + gpakosz
./install.sh --cpp          # C++ 工具链
./install.sh --python       # Python + miniconda
./install.sh --go           # Go
./install.sh --rust         # Rust
./install.sh --tools        # CLI 工具 + Nerd Font + glow
./install.sh --herdr        # Herdr
./install.sh --omp          # omp 配置
./install.sh --interactive  # whiptail / gum / fzf 选择器
./install.sh --offline      # 使用 offline/ 内的包（等价于 --all）
./install.sh --container    # 强制容器 (apt) 模式
```

退出码有含义：必需组件失败会中断；可选项（Mason 包、gpakosz 框架、vcpkg 引导、
Go 工具）失败只告警，不影响其余安装。

## 项目结构

```
envforge/
├── install.sh                     # 主入口
├── Makefile                       # make install / update / nvim-sync / container
├── config/
│   ├── zsh/                       # .zshrc、.zimrc、.ripgreprc
│   ├── nvim/                      # LazyVim 配置，链接到 ~/.config/nvim
│   ├── tmux/tmux.conf.local
│   ├── yazi/
│   ├── herdr/config.toml
│   └── omp/agent/config.yml       # omp 基础配置（不含凭证）
├── scripts/
│   ├── install_*.sh               # 每个组件一个脚本
│   ├── offline.sh                 # 离线安装公共函数
│   ├── download_offline.sh        # 生成离线包
│   ├── interactive.sh             # 组件选择器
│   ├── nvim_sync.sh               # 无头 Lazy 同步并等待 Mason
│   ├── setup_proxy.sh             # 国内镜像
│   └── uninstall.sh
├── containers/                    # Dockerfile、docker-compose.yml、devcontainer
└── offline/                       # 下载的离线包（gitignore）
```

## 公司网络与镜像

```bash
source scripts/setup_proxy.sh     # 自动识别国内网络并导出镜像
./install.sh
```

| 工具 | 镜像变量 |
|---|---|
| GitHub | `GITHUB_MIRROR`（如 `https://ghfast.top/https://github.com`） |
| Homebrew | `HOMEBREW_API_DOMAIN`、`HOMEBREW_BOTTLE_DOMAIN` |
| APT | `APT_MIRROR` |
| Go | `GOPROXY` |
| pip | `PIP_INDEX_URL` |
| npm / nvm | `NVM_NODEJS_ORG_MIRROR` |
| Conda | `CONDA_MIRROR` |
| Rust | `RUSTUP_DIST_SERVER`、`RUSTUP_UPDATE_ROOT` |

安装器自身的开关：

| 变量 | 作用 |
|---|---|
| `SKIP_GO_TOOLS=true` | 跳过 `gopls`/`delve`/`staticcheck` 编译（耗时） |
| `MASON_RESTRICTED=1` | Neovim 只用 `mason.providers.client` 提供者 |
| `DOTFILES_RESTRICTED_NETWORK=1` | 同上 |
| `HTTPS_PROXY` | curl、git 与离线下载器均生效 |

## 离线安装

1. 在有网机器上（需要 python3；建议设 `GITHUB_TOKEN` 避免 60 次/小时 API 限制）：

   ```bash
   export GITHUB_TOKEN=...          # 可选但推荐
   ./scripts/download_offline.sh
   ```

   下载器通过 GitHub API 解析**最新** release 的资源名，不会把版本硬编码进
   `/latest/download/<name>` 这类会 404 的地址。

2. 把整个 `envforge/` 目录拷贝到目标机器。

3. 安装：

   ```bash
   ./install.sh --offline            # 等价于 --all
   ./install.sh --offline --tools    # 或只装子集
   ```

`offline/` 内容：

| 路径 | 内容 |
|---|---|
| `go/` | Go tarball |
| `rust/rust-toolchain.tar.gz` | 完整 `~/.rustup` + `~/.cargo` 快照（无需联网即可装好工具链） |
| `nvim/` | Neovim AppImage（Linux）或 tarball（Linux/macOS）、zimfw、vcpkg |
| `tmux/` | tmux 源码包、gpakosz 框架 |
| `conda/`、`node/` | Miniconda 与 Node.js |
| `bins/` | herdr、omp，以及 eza/bat/rg/fd/fzf/yazi/lazygit/glow 的压缩包 |
| `fonts/` | Meslo Nerd Font zip |

**已知限制**（离线包无法覆盖，属于设计取舍）：

* Neovim 的*插件*、tree-sitter 解析器与 Mason 包首次启动仍需网络。可在有网机器上
  跑一次 `./scripts/nvim_sync.sh`，然后一并拷贝 `~/.local/share/nvim` 与
  `~/.local/share/nvim/mason`。
* Rust 用离线工具链快照安装；`rustup update` 仍需网络。
* 系统包（clang/cmake/zsh/tmux）来自系统包管理器。缺预编译包时安装器只告警，
  随后仍会尝试 `brew`/`apt`，有本地缓存或可达镜像时不会被离线模式拦住。

## Docker

```bash
docker compose -f containers/docker-compose.yml up -d --build
docker compose -f containers/docker-compose.yml exec dev zsh
```

构建参数：

| 参数 | 默认 | 说明 |
|---|---|---|
| `BASE_IMAGE` | `ubuntu:26.04` | 基础镜像 |
| `OFFLINE` | `false` | 执行 `install.sh --all --offline` |
| `SKIP_GO_TOOLS` | `true` | 镜像内跳过 Go 工具编译 |

`./install.sh --container` 只切换 apt 模式，本身不安装任何组件，所以镜像里显式
调用 `--all`。

## Neovim 说明

**受限网络下的 Mason。** 默认提供者包含 `registry-api`，无法访问
`api.mason-registry.dev` 时 `:MasonUpdate` 会一直挂住。改用仅客户端提供者：

```bash
MASON_RESTRICTED=1 nvim
```

**无头初始化。** `nvim --headless "+Lazy! sync" +qa` 会在 Mason 的异步安装完成
前退出。使用带等待的封装脚本：

```bash
./scripts/nvim_sync.sh              # 或 make nvim-sync
NVIM_SYNC_TIMEOUT=1800 ./scripts/nvim_sync.sh
```

**SSH 下的剪贴板。** 检测到 `SSH_TTY`/`SSH_CONNECTION` 时自动启用 OSC 52
（`vim.g.clipboard = "osc52"`），远端没有剪贴板提供者时 `y` 也能进本地剪贴板。
前提：

* 终端支持 —— iTerm2（需勾选 *Applications in terminal may access clipboard*）、
  WezTerm、Kitty、Ghostty；Apple Terminal 不支持。
* tmux —— `set -g allow-passthrough on`（`tmux.conf.local` 已含）。
* 兜底：拖选时按住 Shift（Terminal.app）或 Option（iTerm2），或执行 `:set mouse=`
  后使用终端原生选择。

**主题。** 默认 TokyoNight；Catppuccin 与 Gruvbox 已在
`config/nvim/lua/plugins/colorscheme.lua` 预配置，取消注释对应的
`{ "LazyVim/LazyVim", opts = { colorscheme = "..." } }` 即可。

## 机器特定配置

| 文件 | 用途 |
|---|---|
| `~/.zshrc.local` | 由 `.zshrc` 末尾加载；放密钥、API Key（已 gitignore） |
| `~/.p10k.zsh` | 由 `p10k configure` 生成（已 gitignore） |
| `config/nvim/lazy-lock.json` | LazyVim 自动生成（已 gitignore） |

## 更新与卸载

```bash
git pull
make update          # zimfw 模块 + Lazy 同步（含 Mason 等待）+ tmux 框架
make nvim-sync       # 只更新 Neovim 插件/Mason
./scripts/uninstall.sh   # 移除本仓库创建的符号链接
```

## 快捷键

### Neovim

| 按键 | 功能 |
|---|---|
| `<Space>ff` | 查找文件 |
| `<Space>fg` | 全局搜索 |
| `<Space>e` | 文件浏览器 |
| `<Space>fy` | Yazi |
| `<Space>cp` | Markdown 预览（浏览器） |
| `<Space>st` | TODO 选择器（fzf-lua，回退 Telescope） |
| `<Space>xt` | Trouble 中的 TODO |
| `<C-h/j/k/l>` | 窗口 / tmux 导航 |
| `<C-/>` | 浮动终端 |
| `gcc` | 切换行注释 |
| `sa` / `sr` / `sd` | 添加 / 替换 / 删除包围符号 |

### tmux

| 按键 | 功能 |
|---|---|
| `Ctrl+a` | 前缀键 |
| `Ctrl+a \|` | 水平分割 |
| `Ctrl+a -` | 垂直分割 |
| `Ctrl+h/j/k/l` | 面板导航（nvim 感知） |
| `Alt+1~9` | 切换窗口 |
| `Ctrl+a y` | 打开 Yazi |

### fzf

| 按键 | 功能 |
|---|---|
| `Ctrl+R` | 搜索历史命令 |
| `Ctrl+T` | 查找文件 |
| `Alt+C` | 跳转目录 |
