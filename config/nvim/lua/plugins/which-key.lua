return {
  {
    'folke/which-key.nvim',
    -- version pinned in versions.lua
    event = 'VimEnter',
    opts = {
      -- Group labels for the leader prefixes used across plugin keymaps
      spec = {
        { '<leader>c', group = '[C]ode / CMake' },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>dp', group = '[D]ebug [P]ython' },
        { '<leader>g', group = '[G]it' },
        { '<leader>gf', group = '[G]it [F]ile' },
        { '<leader>gt', group = '[G]it [T]oggle' },
        { '<leader>l', group = '[L]int' },
        { '<leader>m', group = '[M]arkdown' },
        { '<leader>n', group = '[N]oice' },
        { '<leader>o', group = '[O]cto (GitHub)' },
        { '<leader>r', group = '[R]efactor / Rename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>sg', group = '[S]earch [G]it' },
        { '<leader>S', group = '[S]pectre' },
        { '<leader>t', group = '[T]est / Toggle' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>x', group = 'Diagnostics (Trouble)' },
        { '<leader>1', hidden = true },
        { '<leader>2', hidden = true },
        { '<leader>3', hidden = true },
        { '<leader>4', hidden = true },
      },
    },
  },
}
