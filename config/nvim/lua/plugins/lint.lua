return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      python = { "ruff" },
      go = { "golangcilint" },
      -- rust is linted by rust-analyzer (rustaceanvim); nvim-lint has no rustc linter
      cpp = { "cpplint" },
      c = { "cpplint" },
      markdown = { "markdownlint" },
      -- eslint_d only lints when the project has an eslint config; harmless otherwise
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
    }

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function()
        -- Only lint modifiable, real-file buffers
        if vim.bo.modifiable and vim.bo.buftype == "" then
          lint.try_lint(nil, { ignore_errors = true })
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>ll",
      function() require("lint").try_lint() end,
      desc = "Run linters",
    },
  },
}
