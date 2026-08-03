return {
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GRename",
      "GDelete",
      "GBrowse",
    },
  },
  -- GitHub :GBrowse handler and #issue omni-completion for commit messages
  -- Root spec with no trigger would load at startup (and drag fugitive in).
  { "tpope/vim-rhubarb", event = "VeryLazy", dependencies = { "tpope/vim-fugitive" } },
}
