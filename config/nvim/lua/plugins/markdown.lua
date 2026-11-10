-- Markdown preview (LazyVim lang.markdown extra already provides LSP/tools).
-- This file adds an in-browser preview (MarkdownPreview.nvim) + keep the
-- glossnvim?/terminal fallback: `glow` CLI is installed via --tools.
-- MkPreview toggles preview of the current file in the default browser.
return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
    config = function()
      vim.cmd([[do augroup Mkdp
        autocmd!
        autocmd BufEnter *.md setlocal tabstop=2 shiftwidth=2
      augroup END]])
    end,
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>c", group = "code" },
      },
    },
  },
}
