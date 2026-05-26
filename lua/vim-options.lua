-- General editor options
local opt = vim.opt

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

-- Helper for cleaner keymap definitions.
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, {
    noremap = true,
    silent = true,
    desc = desc,
  })
end

-- Neo-tree
map('n', '<C-n>', '<cmd>Neotree filesystem reveal left<CR>', 'Reveal current file in Neo-tree')



-- LSP keymaps
--
-- These mappings call the built-in Neovim LSP functions.
-- They will work once an LSP client is attached to the current buffer.
map('n', '<C-k>', vim.lsp.buf.hover, 'LSP hover documentation')
map('n', '<C-d>', vim.lsp.buf.definition, 'LSP go to definition')
map({ 'n', 'v' }, '<C-a>', vim.lsp.buf.code_action, 'LSP code action')

-- Vivify Markdown preview
--
-- Requires these executables to exist in PATH:
--   viv
--   vivify-server
--
-- Managed by:
--   lua/plugins/vivify.lua
map('n', '<leader>mp', '<cmd>Vivify<CR>', 'Open Vivify Markdown preview')

-- Health Check --
vim.api.nvim_create_user_command('ConfigHealth', function()
  require('health').check()
end, {})
