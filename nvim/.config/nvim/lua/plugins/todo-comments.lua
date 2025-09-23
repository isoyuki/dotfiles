return {
  { 
    'folke/todo-comments.nvim', 
    event = 'VimEnter', 
    dependencies = { 'nvim-lua/plenary.nvim' }, 
    opts = { signs = false },
    keys = {
      { "<leader>st", "<cmd>TodoTelescope<CR>", desc = "Find all todo comments" },
      { "<leader>sx", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>", desc = "Find all todo comments in current buffer" },
    },
  },
}