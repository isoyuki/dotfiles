-- Loaded only when NVIM_IN_EMACS is set (Neovim inside Doom Emacs).
-- Emacs side: doom/lisp/nvim-bridge.el.

local function elisp_str(s)
	return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

local function emacs(form)
	vim.system({ "emacsclient", "-n", "--eval", form }, { text = true }, function(r)
		if r.code ~= 0 then
			vim.schedule(function()
				vim.notify("emacsclient: " .. (r.stderr or ""), vim.log.levels.ERROR)
			end)
		end
	end)
end

_G.EmacsBridge = {}

-- Called by Emacs: nvim --server SOCK --remote-expr "v:lua.EmacsBridge.open(...)".
-- Deferred so the remote call returns at once and :edit runs outside the eval.
function EmacsBridge.open(path, line, col)
	vim.schedule(function()
		path = vim.fn.fnamemodify(path, ":p")
		local target
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == path then
				target = win
				break
			end
		end
		vim.cmd.stopinsert()
		if target then
			vim.api.nvim_set_current_win(target)
		else
			if vim.bo.buftype ~= "" then
				vim.cmd.wincmd("p")
			end
			vim.cmd.edit(vim.fn.fnameescape(path))
		end
		local row = math.min(math.max(line or 1, 1), vim.api.nvim_buf_line_count(0))
		pcall(vim.api.nvim_win_set_cursor, 0, { row, math.max((col or 1) - 1, 0) })
		vim.cmd("normal! zz")
	end)
	return ""
end

-- C-h/j/k/l: move between splits, and into the Emacs window at the edge.
-- Replaces vim-tmux-navigator's maps here only; there is no tmux inside Emacs.
vim.g.tmux_navigator_no_mappings = 1
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
	vim.keymap.set("n", "<C-" .. key .. ">", function()
		local win = vim.api.nvim_get_current_win()
		vim.cmd.wincmd(key)
		if vim.api.nvim_get_current_win() == win then
			emacs(("(my/nvim-windmove '%s)"):format(dir))
		end
	end, { desc = "Window " .. dir .. " (Emacs at the edge)" })
end

local function handoff(what)
	return function()
		emacs(("(my/nvim-handoff '%s %s)"):format(what, elisp_str(vim.fn.getcwd())))
	end
end

local function claude_send()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return vim.notify("Buffer has no file", vim.log.levels.WARN)
	end
	local form = ("(my/nvim-claude-send %s)"):format(elisp_str(file))
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then
		local a, b = vim.fn.line("v"), vim.fn.line(".")
		form = ("(my/nvim-claude-send %s %d %d)"):format(elisp_str(file), math.min(a, b), math.max(a, b))
		vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
	end
	emacs(form)
end

vim.keymap.set("n", "<leader>hg", handoff("magit"), { desc = "Magit status (Emacs)" })
vim.keymap.set("n", "<leader>ha", handoff("agents"), { desc = "Agent list (Emacs SPC l a)" })
vim.keymap.set("n", "<leader>hr", handoff("review"), { desc = "Review queue (Emacs SPC l r)" })
vim.keymap.set({ "n", "x" }, "<leader>hc", claude_send, { desc = "Send @file#L to Claude (Emacs)" })
pcall(function()
	require("which-key").add({ { "<leader>h", group = "[H]and off to Emacs" } })
end)
