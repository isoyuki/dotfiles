return {
  "stevearc/aerial.nvim",
  opts = {
    -- Prefer LSP symbols, fall back to treesitter/markdown
    backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
    attach_mode = "global",
    layout = {
      default_direction = "prefer_right",
      min_width = 28,
    },
    show_guides = true,
    -- Keep the outline in sync with the cursor
    highlight_on_hover = true,
    autojump = false,
    close_on_select = true,
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- optional
  },
}
