-- Terraform filetype detection
vim.filetype.add({
	extension = {
		tf = "terraform",
		tfvars = "terraform-vars",
	},
})

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})
