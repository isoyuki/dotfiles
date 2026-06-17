return {
	"mrcjkb/rustaceanvim",
	-- version pinned in versions.lua
	lazy = false,
	init = function()
		-- rustaceanvim is configured through vim.g.rustaceanvim (no setup() call);
		-- this must be set before the plugin loads. codelldb is auto-detected from
		-- mason (see config/internal.lua), so no dap.adapter path is needed here.
		vim.g.rustaceanvim = {
			server = {
				default_settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						-- Use clippy for on-save checking (richer lints than `cargo check`)
						checkOnSave = true,
						check = { command = "clippy" },
						procMacro = { enable = true },
						inlayHints = { lifetimeElisionHints = { enable = "always" } },
					},
				},
				on_attach = function(_, bufnr)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Rust: " .. desc })
					end
					-- Rust-specific actions layered onto the [C]ode group, rust buffers only.
					map("<leader>cR", function()
						vim.cmd.RustLsp("runnables")
					end, "Runnables")
					map("<leader>cm", function()
						vim.cmd.RustLsp("expandMacro")
					end, "Expand macro")
					map("<leader>cd", function()
						vim.cmd.RustLsp("renderDiagnostic")
					end, "Render diagnostic")
					-- Richer hover than the generic LSP hover (offers grouped code actions)
					map("K", function()
						vim.cmd.RustLsp({ "hover", "actions" })
					end, "Hover actions")
				end,
			},
		}
	end,
}
