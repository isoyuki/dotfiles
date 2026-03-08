return {
  "leoluz/nvim-dap-go",
  config = true,
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  keys = {
    {
      "<leader>dT",
      function() require('dap-go').debug_test() end,
      desc = "DAP: Debug Go test"
    },
  },
}