return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      python = { "ruff" },
      go = { "golangci_lint" },
      rust = { "rustc" },
      cpp = { "cpplint" },
      c = { "cpplint" },
      markdown = { "markdownlint" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        lint.try_lint(nil, { ignore_errors = true })
      end,
    })
  end,
  keys = {
    {
      "<leader>ll",
      function() require("lint").try_lint() end,
      desc = "Toggle linting"
    },
  },
}
