return {
  "kevinhwang91/nvim-bqf",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    auto_enable = true,
    preview = {
      win_height = 12,
      win_vheight = 12,
      delay_syntax = 80,
      border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
    },
    func_map = {
      vsplit = "",
      ptogglemode = "p",
      stoggleup = "",
    },
    filter = {
      fzf = {
        action = "split",
        extra_opts = { "--bind", "ctrl-o:toggle-all" },
      },
    },
  },
}
