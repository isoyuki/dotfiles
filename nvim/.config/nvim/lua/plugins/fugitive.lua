return {
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git Status" },
      { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git Commit" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Git Blame" },
      { "<leader>gl", "<cmd>Git log<CR>", desc = "Git Log" },
    },
  },
  { "tpope/vim-rhubarb" },
}