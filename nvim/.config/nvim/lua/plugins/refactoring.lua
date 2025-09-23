return {
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		lazy = false,
		config = function()
			require("refactoring").setup()

			-- load refactoring Telescope extension
			require("telescope").load_extension("refactoring")
		end,
		keys = {
			{ "<leader>re", ":Refactor extract ", mode = "x", desc = "Refactor: Extract" },
			{ "<leader>rf", ":Refactor extract_to_file ", mode = "x", desc = "Refactor: Extract to file" },
			{ "<leader>rv", ":Refactor extract_var ", mode = "x", desc = "Refactor: Extract var" },
			{ "<leader>ri", ":Refactor inline_var", mode = { "n", "x" }, desc = "Refactor: Inline var" },
			{ "<leader>rI", ":Refactor inline_func", mode = "n", desc = "Refactor: Inline func" },
			{ "<leader>rb", ":Refactor extract_block", mode = "n", desc = "Refactor: Extract block" },
			{ "<leader>rbf", ":Refactor extract_block_to_file", mode = "n", desc = "Refactor: Extract block to file" },
			{
				"<leader>rr",
				function()
					require("telescope").extensions.refactoring.refactors()
				end,
				mode = { "n", "x" },
				desc = "Refactor: Telescope",
			},
		},
	},
}