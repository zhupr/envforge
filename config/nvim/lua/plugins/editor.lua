return {
  -- tmux 导航集成（Ctrl+h/j/k/l 在 Neovim 和 tmux 面板间无缝切换）
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux/Win Left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux/Win Down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux/Win Up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux/Win Right" },
    },
  },

  -- Yazi 文件管理器集成（Neovim 内打开 Yazi）
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>fy", "<cmd>Yazi<cr>", desc = "Open Yazi" },
      { "<leader>fY", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-s>",
        replace_in_directory = "<c-g>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
      },
    },
  },

  -- 文件浏览器增强
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- Git 标记（行级增删改）
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
    },
  },

  -- 更好的搜索替换
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, desc = "Search and Replace" },
    },
  },

  -- 快速跳转
  {
    "folke/flash.nvim",
    opts = {
      search = {
        multi_window = true,
      },
    },
  },

  -- 缩进线（v3 的模块名是 ibl，必须显式声明 main，否则 Lazy 按仓库名推断 v2 模块）
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = true },
    },
  },

  -- Buffer 标签栏
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },
}
