vim.cmd('set expandtab')
vim.cmd('set tabstop=2')
vim.cmd('set softtabstop=2')
vim.cmd('set shiftwidth=2')

-- Setup Lazy Bootloader
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- Nightfox Theme
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      require('nightfox').setup({
        options = {
          colorblind = {
            enable = true,
            severity = {
              protan = 0.8,
              deutan = 0.2,
              tritan = 0.0,
            }
          }
        }
      })
      vim.cmd('colorscheme nightfox')
    end
  },

  -- Telescope Plugin
  {
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
    end
  },
  
  -- Treesitter Plugin
    {
      "nvim-treesitter/nvim-treesitter",
      build = ':TSUpdate',  -- Ensure parsers are installed
      config = function()
        require'nvim-treesitter.configs'.setup {
          ensure_installed = { "lua", "python", "javascript", "go", "c", "html", "css", "rust", "zig", "typescript", "json", "bash" },  -- Install wanted parsers
          sync_install = false,  -- Install parsers synchronously (recommended: false)
          auto_install = true,  -- Automatically install missing parsers
          highlight = {
            enable = true,  -- Enable Tree-sitter highlighting
            additional_vim_regex_highlighting = false,  -- Disable regex highlighting (recommended)
          },
          indent = {
            enable = true,  -- Enable Tree-sitter indentation
          },
          textobjects = {
            enable = true,  -- Enable text objects for navigating code
            select = {
              enable = true,
              lookahead = true,  -- Automatically jump to text objects
            },
          },
        }
        -- Optional: You can manually enable Tree-sitter features for specific languages
        -- require'nvim-treesitter.install'.prefer_git = true  -- Prefer GitHub over the official repository for faster parser installation
    end
  },
}

local opts = {}
-- Setup Lazy.nvim
require('lazy').setup(plugins, opts)

