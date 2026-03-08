return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function(_, opts)
		require("noice").setup(opts)
		-- Kanagawa sets NormalFloat bg to sumiInk0 (darker than Normal bg sumiInk3).
		-- Noice floating windows inherit NormalFloat, making them darker than the editor.
		-- Override noice highlight groups to use Normal bg, matching telescope's approach.
		local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
		local set = vim.api.nvim_set_hl

		-- Content areas
		set(0, "NoiceCmdlinePopup", { link = "Normal" })
		set(0, "NoicePopup", { link = "Normal" })
		set(0, "NoiceConfirm", { link = "Normal" })
		set(0, "NoiceMini", { link = "Normal" })
		set(0, "NoiceSplit", { link = "Normal" })
		set(0, "NoicePopupmenu", { link = "Normal" })

		-- Per-cmdline-type popup borders: noice generates these dynamically and
		-- they inherit NoiceCmdlinePopupBorder -> DiagnosticSignInfo, which has
		-- no bg (falls back to dark NormalFloat). Set bg to match Normal.
		local border_groups = {
			"NoiceCmdlinePopupBorder",
			"NoiceCmdlinePopupBorderCmdline",
			"NoiceCmdlinePopupBorderSearch",
			"NoiceCmdlinePopupBorderLua",
			"NoiceCmdlinePopupBorderHelp",
			"NoiceCmdlinePopupBorderInput",
			"NoiceCmdlinePopupBorderFilter",
			"NoiceCmdlinePopupBorderCalculator",
			"NoicePopupBorder",
			"NoicePopupmenuBorder",
			"NoiceConfirmBorder",
		}
		for _, group in ipairs(border_groups) do
			local existing = vim.api.nvim_get_hl(0, { name = group })
			set(0, group, vim.tbl_extend("force", existing, { bg = normal_bg }))
		end
	end,
	opts = {
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			progress = { enabled = true },
		},
		views = {
			mini = {
				win_options = { winblend = 0 },
			},
		},
		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = true,
			lsp_doc_border = true,
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true },
			},
		},
	},
	keys = {
		{ "<leader>nd", "<cmd>NoiceDismiss<CR>", desc = "Noice: Dismiss notifications" },
		{ "<leader>nl", "<cmd>NoiceLast<CR>", desc = "Noice: Last message" },
		{ "<leader>nh", "<cmd>Noice history<CR>", desc = "Noice: History" },
		{ "<leader>na", "<cmd>Noice all<CR>", desc = "Noice: All messages" },
		{
			"<C-f>",
			function()
				if not require("noice.lsp").scroll(4) then
					return "<C-f>"
				end
			end,
			mode = { "n", "i", "s" },
			expr = true,
			desc = "Scroll forward (noice/lsp docs)",
		},
		{
			"<C-b>",
			function()
				if not require("noice.lsp").scroll(-4) then
					return "<C-b>"
				end
			end,
			mode = { "n", "i", "s" },
			expr = true,
			desc = "Scroll backward (noice/lsp docs)",
		},
	},
}
