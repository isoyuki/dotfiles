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
      "<leader>dpr",
      function() require("dap-python").run_python() end,
      desc = "Run Python debugger"
    },
  },
}