return {
	{
		"stevearc/oil.nvim",
		tag = "v2.13.0",
		opts = {},
		-- Optional dependencies
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer n-web-devicons
		config = function(_, opts)
			require("oil").setup(opts)
		end,
	},
}

