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
			-- version pinned in versions.lua
			build = function()
				vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait()
			end,
		},
		-- Rust tests run through rustaceanvim's bundled neotest adapter
		-- (replaces rouge8/neotest-rust, which needed cargo-nextest)
		"mrcjkb/rustaceanvim",
		-- JS/TS tests via jest (requires jest installed in the project's node_modules)
		"nvim-neotest/neotest-jest",
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
		local adapters = {
			require("neotest-golang")({
				runner = "gotestsum",
			}),
			require("neotest-python")({
				dap = { justMyCode = false },
			}),
			require("rustaceanvim.neotest"),
		}
		-- jest adapter is optional: only added if the plugin is present
		local ok_jest, neotest_jest = pcall(require, "neotest-jest")
		if ok_jest then
			table.insert(adapters, neotest_jest({ jestCommand = "npm test --" }))
		end

		require("neotest").setup({
			adapters = adapters,
			status = { virtual_text = true },
			output = { open_on_run = true },
		})
	end,
}
