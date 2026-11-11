return {
  -- TODO 高亮
  -- LazyVim core already binds <leader>xt / <leader>xT (Trouble) and, when the
  -- editor.fzf extra is enabled, <leader>st (todo-comments.fzf). Re-binding
  -- <leader>st to :TodoTelescope breaks on fzf-only installs (E492), so resolve
  -- the picker at call time instead.
  {
    "folke/todo-comments.nvim",
    keys = {
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      {
        "<leader>xT",
        "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
        desc = "Todo/Fix/Fixme (Trouble)",
      },
      {
        "<leader>st",
        function()
          local fzf = pcall(require, "todo-comments.fzf")
          if fzf then
            require("todo-comments.fzf").todo()
            return
          end
          if vim.fn.exists(":TodoTelescope") == 2 then
            vim.cmd("TodoTelescope")
            return
          end
          vim.notify("No todo picker available (enable editor.fzf or editor.telescope)", vim.log.levels.WARN)
        end,
        desc = "Todo",
      },
    },
  },
}
