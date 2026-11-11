return {
  -- Completion: current LazyVim ships blink.cmp (no nvim-cmp / LuaSnip).
  -- Keep LazyVim defaults; only tweak the accept key to match muscle memory.
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        preset = "default",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
    },
  },

  -- 代码片段（LuaSnip 只在启用 coding.luasnip extra 时存在，缺失时跳过）
  {
    "rafamadriz/friendly-snippets",
    config = function()
      local ok, loader = pcall(require, "luasnip.loaders.from_vscode")
      if ok then loader.lazy_load() end
    end,
  },

  -- Surround
  {
    "nvim-mini/mini.surround",
    keys = {
      { "sa", desc = "Add Surrounding", mode = { "n", "v" } },
      { "sd", desc = "Delete Surrounding" },
      { "sf", desc = "Find Right Surrounding" },
      { "sF", desc = "Find Left Surrounding" },
      { "sh", desc = "Highlight Surrounding" },
      { "sr", desc = "Replace Surrounding" },
    },
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        suffix_last = "l",
        suffix_next = "n",
      },
    },
  },

  -- LSP 配置（动态检测 Python 路径）
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              codeLens = { enable = true },
              completion = { callSnippet = "Replace" },
              doc = { privateName = { "^_" } },
              hint = { enable = true, setType = false, paramType = true, paramName = "Disable" },
            },
          },
        },
        -- pyright pythonPath 在 init.lua 中已全局设置
        ruff = {
          init_options = {
            settings = {
              args = { "--target-version", "py313" },
            },
          },
        },
      },
    },
  },

  -- 格式化
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        sh = { "shfmt" },
        rust = { "rustfmt" },
        go = { "gofmt" },
      },
    },
  },
}
