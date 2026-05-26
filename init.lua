-- Set the Python provider used by Neovim.
-- This should point to the dedicated Neovim Python venv created during setup.
vim.g.python3_host_prog = vim.fn.expand '~/.local/share/nvim/python/venv/bin/python'

-- Bootstrap lazy.nvim if it is not already installed.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})

    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- Load plugins from:
--   ~/.config/nvim/lua/plugins/*.lua
require('lazy').setup {
  { import = 'plugins' },
}

-- Load general Neovim options from:
--   ~/.config/nvim/lua/vim-options.lua
require 'vim-options'
