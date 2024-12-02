return {
  {
    'folke/which-key.nvim',
    tag = 'v3.13.3',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()
    end,
  },
}
