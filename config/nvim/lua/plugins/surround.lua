return {
  "kylechui/nvim-surround",
  tag = "v4.0.5",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "gsa", "<Plug>(nvim-surround-normal)", mode = "n", desc = "Add surrounding" },
    { "gsl", "<Plug>(nvim-surround-normal-cur)", mode = "n", desc = "Surround current line" },
    { "gsd", "<Plug>(nvim-surround-delete)", mode = "n", desc = "Delete surrounding" },
    { "gsc", "<Plug>(nvim-surround-change)", mode = "n", desc = "Change surrounding" },
    { "gs", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Add surrounding" },
    { "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Add surrounding to line" },
  },
}
