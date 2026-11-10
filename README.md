# dotfiles

一键部署开发环境，支持 **macOS**、**Linux**、**Docker 容器**。

**覆盖工具链**: Zsh · Neovim (LazyVim) · tmux · Herdr · omp · C++ (clangd/cmake/vcpkg) · Python (miniconda) · Go · Rust · 现代 CLI 工具 · Glow/Markdown 预览

## 快速开始

```bash
# 克隆
git clone https://github.com/<you>/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles

# 一键安装所有
./install.sh

# 或选择性安装
./install.sh --zsh --nvim       # 仅 zsh + neovim
./install.sh --cpp --python     # 仅 C++ + Python
./install.sh --go --rust        # 仅 Go + Rust

### 交互式选择

```bash
./install.sh --interactive   # whiptail > gum > fzf 菜单勾选组件 + 离线开关
make install-interactive
```
```

### 一行命令（无需克隆）

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/install.sh | bash
```

## 公司网络 / 无法访问 GitHub？

### 方案一：自动配置国内镜像

```bash
# 自动检测并配置中国镜像（清华源、中科大源等）
source scripts/setup_proxy.sh

# 然后正常安装
./install.sh
```

支持的镜像：
| 工具 | 镜像源 |
|------|--------|
| GitHub | ghfast.top 代理 |
| Homebrew | 清华 TUNA |
| APT | 清华 TUNA |
| Go modules | goproxy.cn |
| pip | 清华 TUNA |
| npm | npmmirror.com |
| Conda | 清华 TUNA |
| Rust/Cargo | 中科大 USTC |

### 方案二：离线安装

在有网的机器上下载所有依赖，然后拷贝到目标机器：

```bash
# 1. 在有网的机器上
./scripts/download_offline.sh     # 下载所有二进制包到 offline/ 目录

# 2. 拷贝整个 dotfiles 目录到目标机器（U盘/内网传输）

# 3. 在目标机器上
./install.sh --offline            # 从本地包安装
```

> **状态**：离线链路已接通（`download_offline.sh` ↔ `install.sh --offline` 同步扩展：`bins/` `herdr/` `omp/` `glow/`）。无包时各模块走 warn + 跳过，不再误触联网下载。

### 方案三：Docker 容器（内网镜像源可用）

```bash
# 容器内安装开发环境，本地磁盘挂载到 /workspace
docker compose -f containers/docker-compose.yml up -d --build
docker compose -f containers/docker-compose.yml exec dev zsh
```

### 方案四：手动设置代理

```bash
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
export ALL_PROXY=socks5://proxy.company.com:1080
./install.sh
```

## 安装内容一览

| 组件 | macOS (Homebrew) | Linux (apt) | 配置文件 |
|------|-----------------|-------------|----------|
| **Zsh** | zsh + zimfw | zsh + zimfw | `.zshrc`, `.zimrc` |
| **Prompt** | powerlevel10k | powerlevel10k | `.p10k.zsh` |
| **Neovim** | neovim | AppImage | LazyVim + TokyoNight |
| **tmux** | tmux + gpakosz | tmux + gpakosz | `tmux.conf.local` |
| **C++** | cmake + llvm | cmake + clang | clangd, vcpkg |
| **Python** | miniconda | miniconda | pyright + ruff |
| **Go** | go | go (tarball) | gopls + delve |
| **Rust** | rustup | rustup | rust-analyzer |
| **Node.js** | nvm | nvm | LTS 版本 |
| **CLI 工具** | eza, bat, ripgrep, fzf, fd, yazi, lazygit, wget, jq, tree, htop, glow | 同左 | 别名在 `.zshrc` (`md`/`mdt`)，Neovim `<leader>cp` 预览 |
| **Herdr** | brew / herdr.dev 安装脚本 | 同左 | `~/.config/herdr/config.toml` |
| **omp** | omp.sh 安装脚本 | 同左 | `~/.omp/agent/config.yml`（本机基础配置同步，无 API key） |

## 项目结构

```
dotfiles/
├── install.sh                         # 主入口
├── Makefile                           # make install / update / container
├── config/
│   ├── zsh/
│   │   ├── .zshrc                     # Zsh 配置 (zimfw, fzf, 别名, nvm/conda 懒加载)
│   │   ├── .zimrc                     # Zimfw 模块列表
│   │   └── .ripgreprc                 # ripgrep 默认参数
│   ├── nvim/                          # LazyVim 配置 (符号链接到 ~/.config/nvim)
│   │   ├── init.lua                   # 入口 (自动检测 Python/Node 路径)
│   │   ├── lazyvim.json               # LazyVim extras
│   │   └── lua/
│   │       ├── config/                # lazy.lua, options.lua, keymaps.lua, autocmds.lua
│   │       └── plugins/               # coding, colorscheme, cpp, debug, editor, lsp, ui, util
│   ├── tmux/
│   │   └── tmux.conf.local            # tmux 配置 (gpakosz 框架)
│   └── yazi/
│       ├── yazi.toml                  # Yazi 文件管理器配置
│       └── keymap.toml                # Yazi 快捷键
├── scripts/
│   ├── install_tools.sh               # CLI 工具 (eza, bat, ripgrep, fzf, fd, yazi, lazygit)
│   ├── install_zsh.sh                 # Zsh + zimfw
│   ├── install_nvim.sh                # Neovim + nvm + Node.js
│   ├── install_tmux.sh                # tmux + gpakosz
│   ├── install_cpp.sh                 # C++ 工具链 + vcpkg
│   ├── install_python.sh              # Python + miniconda
│   ├── install_go.sh                  # Go
│   ├── install_rust.sh                # Rust (rustup + rust-analyzer)
│   ├── setup_proxy.sh                 # 自动配置国内镜像
│   ├── download_offline.sh            # 离线包下载器
│   └── uninstall.sh                   # 移除符号链接
├── containers/
│   ├── Dockerfile                     # Ubuntu 开发容器
│   ├── docker-compose.yml             # Docker Compose (挂载本地磁盘)
│   └── .devcontainer/                 # VS Code devcontainer
│       └── devcontainer.json
└── offline/                           # 离线包 (gitignore, 手动管理)
```

## 使用指南

### 安装选项

```bash
./install.sh              # 安装全部
./install.sh --zsh        # 仅 Zsh
./install.sh --nvim       # 仅 Neovim
./install.sh --tmux       # 仅 tmux
./install.sh --cpp        # 仅 C++ 工具链
./install.sh --python     # 仅 Python
./install.sh --go         # 仅 Go
./install.sh --rust       # 仅 Rust
./install.sh --herdr      # 仅 Herdr multiplexer
./install.sh --omp        # 仅 omp agent 配置
./install.sh --interactive # 交互式勾选
./install.sh --offline    # 离线模式
./install.sh --container  # 容器内安装
./install.sh --help       # 查看帮助
```

### 更新

```bash
cd ~/code/dotfiles && git pull

make update               # 更新所有

# 或单独更新
nvim +Lazy update         # Neovim 插件
zsh -c 'source ~/.zim/zimfw.zsh update'  # Zimfw 模块
cd ~/.tmux && git pull    # tmux 框架
```

### 添加新语言

1. 在 `config/nvim/lua/plugins/` 创建 `<lang>.lua`
2. 在 `config/nvim/lazyvim.json` 添加对应的 extras
3. 可选：在 `scripts/` 添加安装脚本

### 切换主题

编辑 `config/nvim/lua/plugins/colorscheme.lua`：TokyoNight / Catppuccin / Gruvbox 预配置，取消注释对应行即可。

### 机器特定设置

- **p10k.zsh**: 安装后运行 `p10k configure`，此文件已 `.gitignore`
- **lazy-lock.json**: LazyVim 自动生成，已 `.gitignore`
- **~/.zshrc.local**: 在 `.zshrc` 末尾自动 source，放 API Key 等机器特定配置

## 卸载

```bash
./scripts/uninstall.sh    # 仅移除符号链接
```

## 快捷键速查

### Neovim
| 快捷键 | 功能 |
|--------|------|
| `<Space>ff` | 查找文件 |
| `<Space>fg` | 全局搜索 |
| `<Space>e` | 文件浏览器 |
| `<Space>fy` | Yazi 文件管理器 |
| `<C-h/j/k/l>` | 窗口/tmux 导航 |
| `<C-/>` | 浮动终端 |
| `gcc` | 切换行注释 |
| `sa/sr/sd` | 添加/替换/删除包围符号 |

### tmux
| 快捷键 | 功能 |
|--------|------|
| `Ctrl+a` | 前缀键 |
| `Ctrl+a \|` | 水平分割 |
| `Ctrl+a -` | 垂直分割 |
| `Ctrl+h/j/k/l` | 面板导航 (nvim 感知) |
| `Alt+1~9` | 切换窗口 |
| `Ctrl+a y` | 打开 Yazi |

### fzf
| 快捷键 | 功能 |
|--------|------|
| `Ctrl+R` | 搜索历史命令 |
| `Ctrl+T` | 查找文件 |
| `Alt+C` | 跳转目录 |
