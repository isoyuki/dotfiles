return {
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"lewis6991/async.nvim",
		},
		-- Keymaps live in keymaps.lua; they are the load trigger.
		config = function()
			require("refactoring").setup()
		end,
	},
}