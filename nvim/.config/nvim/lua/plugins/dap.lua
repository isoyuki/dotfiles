return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
  },
  config = function()
    local dap = require("dap")
    dap.set_log_level('WARN')
  end,
  keys = {
    { '<leader>dt', function() require('dap').toggle_breakpoint() end, desc = 'DAP: Toggle Breakpoint' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'DAP: Continue' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'DAP: Step Into' },
    { '<leader>do', function() require('dap').step_over() end, desc = 'DAP: Step Over' },
    { '<leader>dO', function() require('dap').step_out() end, desc = 'DAP: Step Out' },
    { '<leader>dr', function() require('dap').repl.open() end, desc = 'DAP: Open Repl' },
    { '<leader>dq', function() require('dap').terminate() end, desc = 'DAP: Quit' },
  }
}