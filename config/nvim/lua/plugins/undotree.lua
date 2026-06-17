return {
  "mbbill/undotree",
  event = "VeryLazy",
  init = function()
    vim.g.undotree_WindowLayout = 2 -- tree left, diff at the bottom, full width
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_ShortIndicators = 1
  end,
}
