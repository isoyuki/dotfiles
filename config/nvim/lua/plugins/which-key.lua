return {
  {
    'folke/which-key.nvim',
    tag = 'v3.17.0',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()
    end,
  },
}
