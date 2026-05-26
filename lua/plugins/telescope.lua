return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      local telescope = require 'telescope'
      local builtin = require 'telescope.builtin'
      local themes = require 'telescope.themes'

      telescope.setup {
        extensions = {
          ['ui-select'] = themes.get_dropdown {},
        },
      }

      telescope.load_extension 'ui-select'

      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<C-g>', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<C-b>', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<C-h>', builtin.help_tags, { desc = 'Telescope help tags' })
    end,
  },
}
