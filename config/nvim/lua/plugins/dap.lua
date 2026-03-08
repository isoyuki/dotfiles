return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    dap.set_log_level('WARN')
  end,
}