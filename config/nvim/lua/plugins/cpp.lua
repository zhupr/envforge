return {
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
