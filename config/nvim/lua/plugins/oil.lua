return {
	{
		"stevearc/oil.nvim",
		-- version pinned in versions.lua
		-- Load at startup so oil can hijack the directory buffer for `nvim .`.
		-- A `keys` spec elsewhere (keymaps.lua) would otherwise make this
		-- lazy-loaded, and oil can't take over the dir if it isn't loaded yet.
		lazy = false,
		-- Optional dependencies
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer n-web-devicons
		opts = {
			skip_confirm_for_simple_edits = true,
			watch_for_changes = true,
			delete_to_trash = true, -- send deletions to the system trash, not /dev/null
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				-- Defaults map <C-h>/<C-l> to split/refresh, which clashes with
				-- vim-tmux-navigator's pane navigation. Use alternatives instead.
				["<C-h>"] = false,
				["<C-l>"] = false,
				["<C-r>"] = "actions.refresh",
				["<C-x>"] = { "actions.select", opts = { horizontal = true } },
			},
		},
	},
}
