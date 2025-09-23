vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- open file_browser with the path of the current buffer
vim.keymap.set('n', '<space>fb', ':Telescope file_browser path=%:p:h select_buffer=true<CR>')

-- DAP keymaps
vim.keymap.set('n', '<leader>dt', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle [D]AP Breakpoin[t]' })
vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end, { desc = '[D]AP [C]ontinue' })
vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end, { desc = '[D]AP Step [I]nto' })
vim.keymap.set('n', '<leader>do', function() require('dap').step_over() end, { desc = '[D]AP Step [O]ver' })
vim.keymap.set('n', '<leader>dO', function() require('dap').step_out() end, { desc = '[D]AP Step [O]ut' })
vim.keymap.set('n', '<leader>dr', function() require('dap').repl.open() end, { desc = '[D]AP Open [R]epl' })
vim.keymap.set('n', '<leader>dq', function() require('dap').terminate() end, { desc = '[D]AP [Q]uit' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = '[D]AP [U]I Toggle' })
