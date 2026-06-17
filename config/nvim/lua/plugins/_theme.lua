return {
	{
		"rebelot/kanagawa.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		lazy = false,
		opts = {
			compile = true, -- :KanagawaCompile after changing these opts
			commentStyle = { italic = false },
			keywordStyle = { italic = false },
		},
		config = function(_, opts)
			require("kanagawa").setup(opts)
			vim.cmd.colorscheme("kanagawa-dragon")
			vim.cmd.hi("Comment gui=none")
		end,
	},
}
--
-- -- Lazy
-- return {
-- 	"olimorris/onedarkpro.nvim",
-- 	priority = 1000, -- Ensure it loads first
-- 	config = function(_, opts)
-- 		require("onedarkpro").setup(opts)
-- 		vim.cmd.colorscheme("onedark")
-- 	end,
-- }
