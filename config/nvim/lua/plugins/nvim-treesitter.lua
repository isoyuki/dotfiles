-- nvim-treesitter `main` branch: setup()/install() only manage parsers.
-- Highlight, indent and folds must be enabled per buffer via vim.treesitter.

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

			local function start(buf, lang)
				-- language.add returns nil rather than erroring when the parser is
				-- absent, so the return value has to be checked as well.
				local ok, added = pcall(vim.treesitter.language.add, lang)
				if not ok or not added then
					return false
				end
				vim.treesitter.start(buf, lang)
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				return true
			end

			-- One install attempt per language per session, so a parser that
			-- fails to compile does not retry on every buffer.
			local attempted = {}

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match) or args.match
					if start(args.buf, lang) or attempted[lang] then
						return
					end
					attempted[lang] = true
					if not vim.tbl_contains(ts.get_available(), lang) then
						return
					end
					-- Deferred so mason's bin dir (tree-sitter CLI) is on PATH first
					vim.schedule(function()
						ts.install(lang, { summary = true }):await(function(err)
							if err then
								return
							end
							vim.schedule(function()
								for _, buf in ipairs(vim.api.nvim_list_bufs()) do
									local ft = vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype or nil
									if ft and (vim.treesitter.language.get_lang(ft) or ft) == lang then
										start(buf, lang)
									end
								end
							end)
						end)
					end)
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
