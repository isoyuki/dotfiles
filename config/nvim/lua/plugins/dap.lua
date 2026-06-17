return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    dap.set_log_level('WARN')

    -- Open/close nvim-dap-ui automatically with the debug session. These live
    -- here (not in the dap-ui spec) because a session can be started from any
    -- dap entry point (e.g. <leader>dT via nvim-dap-go) without nvim-dap-ui
    -- being loaded yet; nvim-dap is always loaded first, so registering the
    -- listeners here guarantees they fire. require("dapui") triggers lazy to
    -- load + setup nvim-dap-ui on demand the first time a session initializes.
    dap.listeners.after.event_initialized["dapui_config"] = function()
      require("dapui").open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      require("dapui").close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      require("dapui").close()
    end

    -- Gutter icons for breakpoints and the current frame
    local signs = {
      DapBreakpoint = { text = "●", texthl = "DiagnosticError" },
      DapBreakpointCondition = { text = "◆", texthl = "DiagnosticWarn" },
      DapBreakpointRejected = { text = "○", texthl = "DiagnosticHint" },
      DapLogPoint = { text = "◎", texthl = "DiagnosticInfo" },
      DapStopped = { text = "→", texthl = "DiagnosticOk", linehl = "Visual" },
    }
    for name, sign in pairs(signs) do
      vim.fn.sign_define(name, sign)
    end

    -- Node/TypeScript debugging via js-debug-adapter (installed by mason if the
    -- npm registry allows). Only wire it up when the binary is actually present.
    if vim.fn.executable("js-debug-adapter") == 1 then
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }
      for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch current file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "node",
            sourceMaps = true,
            -- ts-node lets you launch .ts directly without a build step
            runtimeArgs = { "-r", "ts-node/register" },
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end
  end,
}
