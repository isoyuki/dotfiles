return {
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", ":<C-U>TmuxNavigateLeft<cr>", silent = true },
			{ "<c-j>", ":<C-U>TmuxNavigateDown<cr>", silent = true },
			{ "<c-k>", ":<C-U>TmuxNavigateUp<cr>", silent = true },
			{ "<c-l>", ":<C-U>TmuxNavigateRight<cr>", silent = true },
			{ "<c-\\>", ":<C-U>TmuxNavigatePrevious<cr>", silent = true },
			{ "<c-left>", ":<C-U>TmuxNavigateLeft<cr>", silent = true },
			{ "<c-down>", ":<C-U>TmuxNavigateDown<cr>", silent = true },
			{ "<c-up>", ":<C-U>TmuxNavigateUp<cr>", silent = true },
			{ "<c-right>", ":<C-U>TmuxNavigateRight<cr>", silent = true },
		},
	},
}
