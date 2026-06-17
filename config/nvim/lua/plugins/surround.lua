return {
  "kylechui/nvim-surround",
  -- version pinned in versions.lua
  event = "VeryLazy",
  init = function()
    -- Default visual-mode `S`/`gS` clash with flash.nvim's `S` (treesitter jump).
    -- Visual surround is provided below as `gs`/`gS` instead.
    -- Normal-mode defaults (ys/yss/ds/cs/...) stay enabled.
    vim.g.nvim_surround_no_visual_mappings = true
  end,
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
