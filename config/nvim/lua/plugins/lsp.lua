return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- clangd: mason=false means use system-installed clangd
        clangd = {
          mason = false,
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cpp = { "clang-format" },
        c = { "clang-format" },
        hpp = { "clang-format" },
        h = { "clang-format" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        cpp = { "clangtidy" },
        c = { "clangtidy" },
      },
    },
  },
}
