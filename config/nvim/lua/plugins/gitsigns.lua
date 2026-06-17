return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      signs_staged = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      preview_config = { border = 'rounded' },
      current_line_blame = false, -- toggle with <leader>gtb
      current_line_blame_opts = {
        delay = 500,
        virt_text_pos = 'eol',
      },
      on_attach = function(bufnr)
        -- Hunk text object: `dih`/`vah`/`yih` operate on the hunk under the cursor.
        -- Shares the i/a prefix with mini.ai, so only the literal `ih`/`ah` sequence
        -- incurs a timeoutlen wait; all other i{obj}/a{obj} resolve immediately.
        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>',
          { buffer = bufnr, silent = true, desc = 'Select git hunk' })
        vim.keymap.set({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>',
          { buffer = bufnr, silent = true, desc = 'Select git hunk' })
      end,
    },
  },
}
