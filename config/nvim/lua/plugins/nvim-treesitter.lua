return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		config = function()
			require("nvim-treesitter").setup()

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "ruby",
				callback = function()
					vim.bo.indentexpr = ""
				end,
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local map = vim.keymap.set
			map({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer") end)
			map({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner") end)
			map({ "x", "o" }, "af", function() select.select_textobject("@function.outer") end)
			map({ "x", "o" }, "if", function() select.select_textobject("@function.inner") end)
			map({ "x", "o" }, "ac", function() select.select_textobject("@class.outer") end)
			map({ "x", "o" }, "ic", function() select.select_textobject("@class.inner") end)

			map({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer") end)
			map({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer") end)
			map({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer") end)
			map({ "n", "x", "o" }, "][", function() move.goto_next_end("@class.outer") end)
			map({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer") end)
			map({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.outer") end)
			map({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer") end)
			map({ "n", "x", "o" }, "[]", function() move.goto_previous_end("@class.outer") end)
		end,
	},
}
