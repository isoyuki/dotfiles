-- nvim-treesitter `main` branch: setup()/install() only manage parsers.
-- Highlight, indent and folds must be enabled per buffer via vim.treesitter.
local ensure_installed = {
	"bash",
	"c",
	"cpp",
	"diff",
	"git_rebase",
	"gitcommit",
	"go",
	"gomod",
	"gosum",
	"gowork",
	"hcl",
	"html",
	"javascript",
	"jsdoc",
	"json",
	"lua",
	"luadoc",
	"make",
	"markdown",
	"markdown_inline",
	"nix",
	"proto",
	"python",
	"query",
	"regex",
	"rust",
	"terraform",
	"tmux",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup({})
			-- Deferred so mason's bin dir (tree-sitter CLI) is on PATH first
			vim.schedule(function()
				ts.install(ensure_installed)
			end)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match) or args.match
					local ok, added = pcall(vim.treesitter.language.add, lang)
					if not ok or not added then
						return
					end
					vim.treesitter.start(args.buf, lang)
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			-- Swap the parameter/argument under the cursor with the next/previous
			-- one. Lives in the [C]ode group; cp/cP are free in the leader space.
			local swap = require("nvim-treesitter-textobjects.swap")
			vim.keymap.set("n", "<leader>cp", function()
				swap.swap_next("@parameter.inner", "textobjects")
			end, { desc = "Swap parameter with next" })
			vim.keymap.set("n", "<leader>cP", function()
				swap.swap_previous("@parameter.inner", "textobjects")
			end, { desc = "Swap parameter with previous" })

			-- Around/inside selections (af/if/ac/ic/aa/ia) are provided by
			-- mini.ai using this plugin's textobject queries; only motions here.
			local move = require("nvim-treesitter-textobjects.move")
			local motions = {
				goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
				goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
				goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
				goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
			}
			for method, mappings in pairs(motions) do
				for lhs, capture in pairs(mappings) do
					vim.keymap.set({ "n", "x", "o" }, lhs, function()
						move[method](capture, "textobjects")
					end, { desc = method:gsub("_", " ") .. " " .. capture })
				end
			end
		end,
	},
}
