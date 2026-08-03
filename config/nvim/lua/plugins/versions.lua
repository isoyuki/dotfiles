-- Release pins (single source of truth — don't repeat tags in plugin specs).
-- Latest stable as of 2026-06-12. Plugins omitted here either do not cut
-- useful releases or are intentionally tracking a maintained branch in
-- lazy-lock.json (e.g. nvim-treesitter `main`, plenary, nvim-lspconfig).
-- A `commit`/`tag`/`version` here is a hard pin: it overrides lazy-lock.json
-- and `:Lazy update` will not move it.
--
-- `optional = true` is applied to every entry below (see bottom of file) so a
-- stale pin can't install a plugin nothing else declares.
--
-- `lazy = true` on some entries is not redundant: lazy.nvim only infers
-- lazy-loading for plugins that are *exclusively* dependencies, and the root
-- fragment this file creates cancels that inference. Without it, every
-- dependency-only plugin here loads at startup.
local pins = {
	{ "L3MON4D3/LuaSnip", lazy = true, tag = "v2.5.0" },
	{ "MeanderingProgrammer/render-markdown.nvim", tag = "v8.12.0" },
	{ "MunifTanjim/nui.nvim", lazy = true, tag = "0.4.0" },
	{ "folke/flash.nvim", tag = "v2.1.0" },
	{ "folke/lazydev.nvim", tag = "v1.10.0" },
	{ "folke/noice.nvim", tag = "v4.10.0" },
	{ "folke/todo-comments.nvim", tag = "v1.5.0" },
	-- Commit pin (not a tag): latest release v3.7.1 predates Neovim 0.12's
	-- treesitter decoration-provider change and errors on render. This commit is
	-- on `main` and has the `_on_range` fix. Switch to `tag = "v3.x.x"` once a
	-- release > v3.7.1 ships.
	{ "folke/trouble.nvim", branch = "main", commit = "bd67efe408d4816e25e8491cc5ad4088e708a69a" },
	{ "folke/which-key.nvim", tag = "v3.17.0" },
	{ "fredrikaverpil/neotest-golang", lazy = true, tag = "v2.9.0" },
	{ "jay-babu/mason-nvim-dap.nvim", lazy = true, branch = "main", commit = "9a10e096703966335bd5c46c8c875d5b0690dade" },
	{ "kevinhwang91/nvim-bqf", tag = "v1.1.1" },
	{ "kylechui/nvim-surround", tag = "v4.0.5" },
	{ "lambdalisue/vim-suda", tag = "v1.2.4" },
	{ "lewis6991/gitsigns.nvim", tag = "v2.1.0" },
	{ "lukas-reineke/indent-blankline.nvim", tag = "v3.9.1" },
	{ "mfussenegger/nvim-dap", lazy = true, branch = "master", commit = "531771530d4f82ad2d21e436e3cc052d68d7aebb" },
	{ "leoluz/nvim-dap-go", lazy = true, branch = "main", commit = "b4421153ead5d726603b02743ea40cf26a51ed5f" },
	{ "mrcjkb/rustaceanvim", tag = "v9.0.5" },
	{ "nvim-neotest/neotest", tag = "v5.18.0" },
	{ "nvim-neotest/nvim-nio", lazy = true, tag = "v1.10.1" },
	{ "nvim-telescope/telescope.nvim", tag = "v0.2.2" },
	{ "rcarriga/nvim-dap-ui", lazy = true, branch = "master", commit = "1a66cabaa4a4da0be107d5eda6d57242f0fe7e49" },
	{ "theHamsta/nvim-dap-virtual-text", lazy = true, branch = "master", commit = "fbdb48c2ed45f4a8293d0d483f7730d24467ccb6" },
	{ "rcarriga/nvim-notify", lazy = true, tag = "v3.15.0" },
	{ "stevearc/aerial.nvim", tag = "v4.0.0" },
	{ "stevearc/conform.nvim", tag = "v9.1.0" },
	{ "stevearc/dressing.nvim", tag = "v3.1.1" },
	{ "stevearc/oil.nvim", tag = "v2.16.0" },
	{ "williamboman/mason-lspconfig.nvim", lazy = true, tag = "v2.3.0" },
	{ "williamboman/mason.nvim", lazy = true, tag = "v2.3.1" },
	{ "echasnovski/mini.nvim", tag = "v0.17.0" },
	{ "echasnovski/mini.icons", lazy = true, tag = "v0.17.0" },
}

for _, pin in ipairs(pins) do
	pin.optional = true
end

return pins
