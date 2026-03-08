return {
	"nvim-pack/nvim-spectre",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>Sr", function() require("spectre").open() end, desc = "Search and Replace (Spectre)" },
		{ "<leader>Sw", function() require("spectre").open_visual({ select_word = true }) end, mode = { "n", "v" }, desc = "Spectre: Current word" },
		{ "<leader>Sf", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Spectre: Current file" },
	},
}
