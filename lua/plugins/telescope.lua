return { 
-- Telescope Plugin
    "nvim-telescope/telescope.nvim",
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')

      -- Keymaps for Telescope
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<C-g>', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<C-b>', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<C-h>', builtin.help_tags, { desc = 'Telescope help tags' })
      --- Keymaps for Neo-Tree
      vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>')
    end
}
 
