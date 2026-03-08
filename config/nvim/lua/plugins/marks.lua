return {
	"chentoast/marks.nvim",
	event = "BufReadPost",
	opts = {
		default_mappings = true,
		signs = true,
		mappings = {
			set_next = "m,",
			next = "m]",
			prev = "m[",
			preview = "m:",
			delete_line = "dm-",
			delete_buf = "dm<space>",
		},
	},
}
