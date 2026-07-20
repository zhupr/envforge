-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- 以下仅添加 LazyVim 未内置的自定义 autocmd

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- 保存时自动去除行尾空格（LazyVim 未内置）
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = { "*" },
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})
