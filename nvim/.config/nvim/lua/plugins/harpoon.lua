return {
  -- luacheck: ignore
  -- Fast file navigation (Uses SPC a)
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    event = 'VeryLazy',
    config = function()
      -- REQUIRED
      require('harpoon'):setup()
      -- REQUIRED
    end,
  },
}