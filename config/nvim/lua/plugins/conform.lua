return {
	{ -- Autoformat
		"stevearc/conform.nvim",
		-- version pinned in versions.lua
		event = "BufWritePre",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- No format-on-save for markdown (still formats via <leader>f).
				if vim.bo[bufnr].filetype == "markdown" then
					return
				end
				local disable_lsp = { c = true, cpp = true }
				return {
					timeout_ms = 500,
					lsp_format = disable_lsp[vim.bo[bufnr].filetype] and "never" or "fallback",
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				-- goimports already applies gofmt; chaining both risks the 500ms budget
			go = { "goimports" },
				rust = { "rustfmt" },
				python = { "ruff_organize_imports", "ruff_format" },
				sage = { "ruff_format" },
				terraform = { "terraform_fmt" },
				["terraform-vars"] = { "terraform_fmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				-- prettierd (fast daemon) with prettier as fallback; first available wins
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				-- Fallback for any filetype without a dedicated formatter above.
				-- trim_whitespace is a conform built-in (no external tool needed).
				["_"] = { "trim_whitespace" },
			},
		},
	},
}
