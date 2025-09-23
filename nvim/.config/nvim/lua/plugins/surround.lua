return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration options go here
    })
  end,
  keys = {
    { "ys", "<Plug>(nvim-surround-normal)", mode = "n", desc = "Add surrounding" },
    { "yss", "<Plug>(nvim-surround-normal-line)", mode = "n", desc = "Add surrounding to line" },
    { "ds", "<Plug>(nvim-surround-delete)", mode = "n", desc = "Delete surrounding" },
    { "cs", "<Plug>(nvim-surround-change)", mode = "n", desc = "Change surrounding" },
    { "S", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Add surrounding" },
    { "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Add surrounding to line" },
  },
}
