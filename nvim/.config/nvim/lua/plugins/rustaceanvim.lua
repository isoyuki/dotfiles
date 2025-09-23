return {
	"mrcjkb/rustaceanvim",
	version = "^5", -- Recommended
	ft = { "rust" },
	dependencies = {
		"mfussenegger/nvim-dap",
	},
  keys = {
    { "<leader>rr", "<cmd>Rustaceanvim run<CR>", desc = "Run Rustaceanvim" },
    { "<leader>rh", "<cmd>Rustaceanvim hover actions<CR>", desc = "Hover Actions" },
    { "<leader>ra", "<cmd>Rustaceanvim code_action<CR>", desc = "Code Action" },
    { "<leader>re", "<cmd>Rustaceanvim explain<CR>", desc = "Explain Error" },
  },
}