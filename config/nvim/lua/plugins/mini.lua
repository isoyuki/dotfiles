return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    -- version pinned in versions.lua
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      --  - vif  - select inside function, vac - around class (treesitter)
      --  - vaa  - around argument (built-in `a` textobject)
      local ai = require('mini.ai')
      ai.setup {
        n_lines = 500,
        custom_textobjects = {
          -- Treesitter-powered textobjects; queries come from
          -- nvim-treesitter-textobjects (queries/*/textobjects.scm).
          f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
          c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
          o = ai.gen_spec.treesitter {
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          },
        },
      }

      -- mini.surround DISABLED - using nvim-surround instead (ys/ds/cs)
      -- to avoid conflict with Flash's `s` key.

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}
