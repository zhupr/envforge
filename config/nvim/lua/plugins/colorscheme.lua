return {
  -- 主题：TokyoNight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",        -- storm / moon / night / day
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark",
      },
    },
  },
  -- 主题：Catppuccin（备选）
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",     -- latte / frappe / macchiato / mocha
      transparent_background = false,
      term_colors = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        notify = true,
        mini = { enabled = true, indentscope_color = "" },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      },
    },
  },
  -- 设置默认主题（二选一，取消注释想要的）
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
  -- { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
