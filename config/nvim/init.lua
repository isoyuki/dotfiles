require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

if vim.env.NVIM_IN_EMACS then
	require("emacs_bridge")
end
