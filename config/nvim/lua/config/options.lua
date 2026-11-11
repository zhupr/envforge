-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

opt.relativenumber = true    -- 相对行号
opt.tabstop = 4              -- Tab 宽度
opt.shiftwidth = 4           -- 缩进宽度
opt.scrolloff = 8            -- 光标距顶部/底部保留 8 行
opt.sidescrolloff = 8        -- 光标距左/右保留 8 列
opt.undolevels = 10000       -- 撤销历史深度

-- OSC 52 clipboard: works over SSH where there is no local clipboard provider
-- (and inside tmux with `set -g allow-passthrough on`).
-- Local sessions keep the native provider so desktop copy/paste stays intact.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  vim.g.clipboard = "osc52"
  opt.clipboard = "unnamedplus"
end
