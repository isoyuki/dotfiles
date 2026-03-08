return {
	"nvim-treesitter/nvim-treesitter-context",
	event = "BufReadPost",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		max_lines = 3,
		multiline_threshold = 1,
	},
	keys = {
		{
			"gC",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to context",
		},
		{ "<leader>tc", "<cmd>TSContextToggle<CR>", desc = "Toggle Treesitter Context" },
	},
}
