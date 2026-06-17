return {
  "mfussenegger/nvim-dap-python",
  lazy = true,
  config = function()
    local python = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
    require("dap-python").setup(python)
  end,
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  keys = {
    {
      "<leader>dpm",
      function() require("dap-python").test_method() end,
      desc = "DAP Python: Debug nearest test method",
    },
    {
      "<leader>dpc",
      function() require("dap-python").test_class() end,
      desc = "DAP Python: Debug nearest test class",
    },
    {
      "<leader>dps",
      function() require("dap-python").debug_selection() end,
      mode = "v",
      desc = "DAP Python: Debug selection",
    },
  },
}
