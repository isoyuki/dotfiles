return {
	"sindrets/diffview.nvim",
	keys = {
		{
			"<leader>gd",
			function()
				-- require("diffview").extensions.refactoring.refactors()
				if next(require("diffview.lib").views) == nil then
					vim.cmd("DiffviewOpen")
				else
					vim.cmd("DiffviewClose")
				end
			end,
			desc = "Tobble Diffview",
		},
	},
}
