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
  { "tpope/vim-rhubarb", dependencies = { "tpope/vim-fugitive" } },
}
