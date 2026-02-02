return {
  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    keys = {
      { "gcc", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle comment on current line" },
      { "gc", function() require("Comment.api").toggle.linewise(vim.fn.visualmode()) end, mode = "v", desc = "Toggle comment on selected lines" },
    },
  },
}