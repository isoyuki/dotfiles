return {
  -- luacheck: ignore
  -- Fast file navigation (Uses SPC a)
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    event = 'VeryLazy',
    config = function()
      -- REQUIRED
      require('harpoon'):setup()
      -- REQUIRED
    end,
    keys = {
      {
        '<C-e>',
        function()
          local harpoon = require 'harpoon'
          -- -- basic telescope configuration
          local conf = require('telescope.config').values
          local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
              table.insert(file_paths, item.value)
            end

            require('telescope.pickers')
              .new({}, {
                prompt_title = 'Harpoon',
                finder = require('telescope.finders').new_table {
                  results = file_paths,
                },
                previewer = conf.file_previewer {},
                sorter = conf.generic_sorter {},
              })
              :find()
          end
          toggle_telescope(harpoon:list())
        end,
        desc = 'Open harpoon window',
      },
      {
        '<leader>a',
        function()
          require('harpoon'):list():add()
        end,
        desc = 'Harpoon: Add file',
      },
      {
        '<C-h>',
        function()
          require('harpoon'):list():select(1)
        end,
        desc = 'Harpoon: Select file 1',
      },
      {
        '<C-t>',
        function()
          require('harpoon'):list():select(2)
        end,
        desc = 'Harpoon: Select file 2',
      },
      {
        '<C-n>',
        function()
          require('harpoon'):list():select(3)
        end,
        desc = 'Harpoon: Select file 3',
      },
      {
        '<C-s>',
        function()
          require('harpoon'):list():select(4)
        end,
        desc = 'Harpoon: Select file 4',
      },
      {
        '<C-S-P>',
        function()
          require('harpoon'):list():prev()
        end,
        desc = 'Harpoon: Previous file',
      },
      {
        '<C-S-N>',
        function()
          require('harpoon'):list():next()
        end,
        desc = 'Harpoon: Next file',
      },
    },
  },
}