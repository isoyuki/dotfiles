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
                                        layout_config = {
                                                horizontal = {
                                                        preview_width = 0.5,
                                                },
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
