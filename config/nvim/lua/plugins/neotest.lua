return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
		{
			"fredrikaverpil/neotest-golang",
			version = "*",
			build = function()
				vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
			end,
		},
		"rouge8/neotest-rust",
	},
	keys = {
		{ "<leader>tn", function() require("neotest").run.run() end, desc = "Neotest: Run nearest" },
		{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Neotest: Run file" },
		{ "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Neotest: Run all" },
		{ "<leader>tl", function() require("neotest").run.run_last() end, desc = "Neotest: Run last" },
		{ "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Neotest: Toggle summary" },
		{ "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Neotest: Toggle output panel" },
		{ "<leader>tO", function() require("neotest").output.open({ enter = true }) end, desc = "Neotest: Show output" },
		{ "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Neotest: Debug nearest" },
		{ "<leader>tS", function() require("neotest").run.stop() end, desc = "Neotest: Stop" },
		{ "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Neotest: Watch file" },
		{ "]T", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
		{ "[T", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Previous failed test" },
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-golang")({
					runner = "gotestsum",
				}),
				require("neotest-python"),
				require("neotest-rust"),
			},
			status = { virtual_text = true },
			output = { open_on_run = true },
		})
	end,
}
