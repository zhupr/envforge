# Neovim 配置 (LazyVim)

开箱即用的 Neovim 配置，基于 [LazyVim](https://github.com/LazyVim/LazyVim) 框架。

## 安装

```bash
# 1. 备份现有配置
mv ~/.config/nvim ~/.config/nvim.bak

# 2. 复制此目录
cp -r /Users/coco/Documents/配置shell/nvim-config ~/.config/nvim

# 3. 启动 Neovim（首次会自动安装所有插件）
nvim
```

## 依赖

- Neovim >= 0.9.0
- Git
- 一个 [Nerd Font](https://www.nerdfonts.com/) 字体
- Node.js（用于部分 LSP）
- ripgrep（用于模糊搜索）
- fd（用于文件查找）

```bash
# macOS
brew install neovim git ripgrep fd node
```

## 核心快捷键

| 快捷键 | 功能 |
|--------|------|
| `<Space>` | Leader 键 |
| `<leader>ff` | 查找文件 |
| `<leader>fg` | 全局搜索 (grep) |
| `<leader>fb` | Buffer 列表 |
| `<leader>fr` | 最近文件 |
| `<leader>e` | 文件浏览器 |
| `<leader>fy` | Yazi 文件管理器 |
| `<C-/>` | 浮动终端 |
| `<S-h>` / `<S-l>` | 切换 Buffer |
| `<C-h/j/k/l>` | 窗口/tmux 面板导航 |
| `gcc` | 切换行注释 |
| `sa` / `sr` / `sd` | 添加/替换/删除包围符号 |
| `<C-s>` | 保存文件 |

## 主题切换

编辑 `lua/plugins/colorscheme.lua`，注释/取消注释想要的主题：

```lua
{ "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
-- { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
```

## 语言支持

默认启用了：TypeScript、Python、Rust、Go、JSON、YAML、Markdown、Docker、Tailwind

添加新语言支持，编辑 `lazyvim.json` 的 extras 列表。

## 更新插件

在 Neovim 中运行：
- `:Lazy` - 查看/更新插件
- `:Lazy update` - 更新所有插件
- `:Mason` - 管理 LSP/格式化工具
