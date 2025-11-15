return {
  {
    "stevearc/aerial.nvim",
    keys = {
      { "<leader>a", "<cmd>AerialToggle<CR>", desc = "Toggle Aerial" },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    keys = {
      { "<leader>p", "<cmd>BqfTogglePreview<CR>", desc = "Toggle Preview" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>dt", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "DAP: Set Conditional Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP: Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "DAP: Run to Cursor" },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP: Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP: Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "DAP: Step Out" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP: Open Repl" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "DAP: Quit" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "Dap UI",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gd",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diffview",
      },
      { "<leader>gfh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: File History" },
    },
  },
  {
    "folke/flash.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git Status" },
      { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git Commit" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Git Blame" },
      { "<leader>gl", "<cmd>Git log<CR>", desc = "Git Log" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", desc = "Preview Hunk" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset Hunk" },
      { "<leader>gS", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage Hunk" },
      { "<leader>gSb", "<cmd>Gitsigns stage_buffer<CR>", desc = "Stage Buffer" },
      { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "Undo Stage Hunk" },
      { "<leader>gB", function() require("gitsigns").blame_line({ full = true }) end, desc = "Gitsigns: Blame Line" },
      { "<leader>gD", "<cmd>Gitsigns diffthis '~'<CR>", desc = "Gitsigns: Diff This" },
      { "]h", "<cmd>Gitsigns next_hunk<CR>", desc = "Next Hunk" },
      { "[h", "<cmd>Gitsigns prev_hunk<CR>", desc = "Previous Hunk" },
    },
  },
  {
    "ThePrimeagen/harpoon",
    keys = {
      {
        "<C-e>",
        function()
          local harpoon = require("harpoon")
          local conf = require("telescope.config").values
          local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
              table.insert(file_paths, item.value)
            end

            require("telescope.pickers")
              .new({}, {
                prompt_title = "Harpoon",
                finder = require("telescope.finders").new_table({
                  results = file_paths,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
              })
              :find()
          end
          toggle_telescope(harpoon:list())
        end,
        desc = "Open harpoon window",
      },
      {
        "<leader>a",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon: Add file",
      },
      {
        "<C-h>",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "Harpoon: Select file 1",
      },
      {
        "<C-t>",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Harpoon: Select file 2",
      },
      {
        "<C-n>",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Harpoon: Select file 3",
      },
      {
        "<C-s>",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Harpoon: Select file 4",
      },
      {
        "<C-S-P>",
        function()
          require("harpoon"):list():prev()
        end,
        desc = "Harpoon: Previous file",
      },
      {
        "<C-S-N>",
        function()
          require("harpoon"):list():next()
        end,
        desc = "Harpoon: Next file",
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>E", "<cmd>Neotree toggle<CR>", desc = "Toggle Neotree" },
      { "<leader>ef", "<cmd>Neotree reveal<CR>", desc = "Neotree: Reveal file" },
    },
  },
  {
    "stevearc/oil.nvim",
    keys = {
      { "<leader>o", "<cmd>Oil<CR>", desc = "Open Oil" },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    keys = {
      { "<leader>re", ":Refactor extract ", mode = "x", desc = "Refactor: Extract" },
      { "<leader>rf", ":Refactor extract_to_file ", mode = "x", desc = "Refactor: Extract to file" },
      { "<leader>rv", ":Refactor extract_var ", mode = "x", desc = "Refactor: Extract var" },
      { "<leader>ri", ":Refactor inline_var", mode = { "n", "x" }, desc = "Refactor: Inline var" },
      { "<leader>rI", ":Refactor inline_func", mode = "n", desc = "Refactor: Inline func" },
      { "<leader>rb", ":Refactor extract_block", mode = "n", desc = "Refactor: Extract block" },
      { "<leader>rbf", ":Refactor extract_block_to_file", mode = "n", desc = "Refactor: Extract block to file" },
      {
        "<leader>rr",
        function()
          require("telescope").extensions.refactoring.refactors()
        end,
        mode = { "n", "x" },
        desc = "Refactor: Telescope",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>sh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "[S]earch [H]elp",
      },
      {
        "<leader>sk",
        function()
          require("telescope.builtin").keymaps()
        end,
        desc = "[S]earch [K]eymaps",
      },
      {
        "<leader>sf",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "[S]earch [F]iles",
      },
      {
        "<leader>ss",
        function()
          require("telescope.builtin").builtin()
        end,
        desc = "[S]earch [S]elect Telescope",
      },
      {
        "<leader>sw",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "[S]earch current [W]ord",
      },
      {
        "<leader>sg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "[S]earch by [G]rep",
      },
      {
        "<leader>sd",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "[S]earch [D]iagnostics",
      },
      {
        "<leader>sr",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "[S]earch [R]esume",
      },
      {
        "<leader>s.",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = '[S]earch Recent Files ("." for repeat)',
      },
      {
        "<leader><leader>",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "[ ] Find existing buffers",
      },
      {
        "<leader>/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = "[/] Fuzzily search in current buffer",
      },
      {
        "<leader>s/",
        function()
          require("telescope.builtin").live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          })
        end,
        desc = "[S]earch [/] in Open Files",
      },
      {
        "<leader>sn",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "[S]earch [N]eovim files",
      },
      {
        "<leader>sgf",
        function()
          require("telescope.builtin").git_files()
        end,
        desc = "[S]earch [G]it [F]iles",
      },
      {
        "<leader>sgg",
        function()
          require("telescope.builtin").git_status()
        end,
        desc = "[S]earch [G]it [S]tatus",
      },
      {
        "<leader>sgc",
        function()
          require("telescope.builtin").git_commits()
        end,
        desc = "[S]earch [G]it [C]ommits",
      },
      {
        "<leader>sgb",
        function()
          require("telescope.builtin").git_branches()
        end,
        desc = "[S]earch [G]it [B]ranches",
      },
    },
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = {
      { "<space>fb", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", desc = "[F]ile [B]rowser" },
    },
  },
  {
    "folke/todo-comments.nvim",
    keys = {
      { "<leader>st", "<cmd>TodoTelescope<CR>", desc = "Find all todo comments" },
      { "<leader>sx", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>", desc = "Find all todo comments in current buffer" },
    },
  },
  {
    "folke/trouble.nvim",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undo Tree" },
    },
  },
}