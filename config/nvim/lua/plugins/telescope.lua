return {
        { -- Fuzzy Finder (files, lsp, etc)
                "nvim-telescope/telescope.nvim",
                event = "VimEnter",
                -- branch = '0.1.8',
                dependencies = {
                        "nvim-lua/plenary.nvim",
                        {
                                "nvim-telescope/telescope-fzf-native.nvim",
                                build = "make",
                                cond = function()
                                        return vim.fn.executable("make") == 1
                                end,
                        },
                        { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
                },
                config = function()
                        require("telescope").setup({
                                defaults = {
                                        path_display = { "truncate" },
                                        layout_config = {
                                                horizontal = {
                                                        preview_width = 0.5,
                                                },
                                        },
                                        -- Skip noisy directories in live_grep/grep_string
                                        file_ignore_patterns = { "%.git/", "node_modules/", "vendor/" },
                                        mappings = {
                                                i = {
                                                        -- Scroll the preview window
                                                        ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
                                                        ["<C-u>"] = require("telescope.actions").preview_scrolling_up,
                                                        -- Send all results to the quickfix list and open it
                                                        ["<C-q>"] = function(bufnr)
                                                                require("telescope.actions").send_to_qflist(bufnr)
                                                                require("telescope.actions").open_qflist(bufnr)
                                                        end,
                                                        -- Narrow the current results into a fresh fuzzy search
                                                        ["<C-Enter>"] = require("telescope.actions").to_fuzzy_refine,
                                                },
                                        },
                                },
                                pickers = {
                                        find_files = {
                                                hidden = true,
                                        },
                                        buffers = {
                                                sort_mru = true,
                                                ignore_current_buffer = true,
                                        },
                                },
                                extensions = {},
                        })

                        -- Enable Telescope extensions if they are installed
                        pcall(require("telescope").load_extension, "fzf")
                end,
        },
        {
                "nvim-telescope/telescope-file-browser.nvim",
                dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        },
}
