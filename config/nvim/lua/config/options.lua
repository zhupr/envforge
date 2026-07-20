-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

opt.relativenumber = true    -- 相对行号
opt.tabstop = 4              -- Tab 宽度
opt.shiftwidth = 4           -- 缩进宽度
opt.scrolloff = 8            -- 光标距顶部/底部保留 8 行
opt.sidescrolloff = 8        -- 光标距左/右保留 8 列
opt.undolevels = 10000       -- 撤销历史深度
