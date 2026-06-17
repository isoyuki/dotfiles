return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"mfussenegger/nvim-dap",
		"nvim-neotest/nvim-nio",
		{
			-- Install debug adapters via mason
			"jay-babu/mason-nvim-dap.nvim",
			dependencies = { "williamboman/mason.nvim" },
			opts = {
				ensure_installed = { "delve", "debugpy", "codelldb" },
				-- Adapters are configured by nvim-dap-go, nvim-dap-python and
				-- rustaceanvim; mason-nvim-dap only installs the binaries.
				handlers = nil,
			},
		},
		"leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
		{
			-- Show variable values inline while debugging
			"theHamsta/nvim-dap-virtual-text",
			opts = {
				virt_text_pos = "eol",
			},
		},
	},
	config = function()
		local dapui = require("dapui")
		dapui.setup({
			-- Play/step/stop controls in the repl element's winbar
			controls = { enabled = true, element = "repl" },
			-- Truncate long variable values so the scopes pane stays readable
			render = { max_value_lines = 3 },
			layouts = {
				{
					position = "left",
					size = 40,
					elements = {
						{ id = "scopes", size = 0.30 },
						{ id = "breakpoints", size = 0.20 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
				},
				{
					position = "bottom",
					size = 10,
					elements = {
						{ id = "repl", size = 0.5 },
						{ id = "console", size = 0.5 },
					},
				},
			},
		})

		-- The auto open/close listeners live in the nvim-dap spec (plugins/dap.lua)
		-- so they are registered for sessions started from any entry point, even
		-- when this plugin has not been loaded yet.
	end,
}
