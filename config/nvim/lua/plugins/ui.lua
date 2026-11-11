return {
  -- 通知美化
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      render = "compact",
      stages = "fade_in_slide_out",
    },
  },

  -- 底部状态栏（扩展 LazyVim 默认 lualine）
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "" } },
        },
      },
    },
  },

  -- Dashboard 启动页（自定义 logo）
  {
    "nvimdev/dashboard-nvim",
    opts = function(_, opts)
      local logo = [[
       ███████╗██╗██╗  ██╗██╗   ██╗██╗███╗   ██╗
       ██╔════╝██║╚██╗██╔╝██║   ██║██║████╗  ██║
       █████╗  ██║ ╚███╔╝ ██║   ██║██║██╔██╗ ██║
       ██╔══╝  ██║ ██╔██╗ ██║   ██║██║██║╚██╗██║
       ██║     ██║██╔╝ ██╗╚██████╔╝██║██║ ╚████║
       ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
      ]]
      logo = string.rep("\n", 8) .. logo .. "\n\n"
      -- LazyVim only pre-populates opts.config when the ui.dashboard-nvim
      -- extra is enabled; create it so this spec works either way.
      opts.config = opts.config or {}
      opts.config.header = vim.split(logo, "\n")
    end,
  },

  -- Noice（命令行/消息/UI 美化，扩展 LazyVim 默认配置）
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
    },
  },
}
