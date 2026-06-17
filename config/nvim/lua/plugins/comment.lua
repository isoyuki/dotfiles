return {
  {
    'numToStr/Comment.nvim',
    -- Let the plugin define its own mappings (gcc, gc{motion}, gbc, gb, gco,
    -- gcO, gcA). Custom `keys` previously shadowed them with a broken visual
    -- mode mapping (`visualmode()` is stale until visual mode is left).
    event = 'VeryLazy',
    opts = {},
  },
}
