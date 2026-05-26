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

-- Markdown Preview
--
-- These commands are created by markdown-preview.nvim.
-- The keymaps are safe because <cmd> mappings resolve the command when used.
map('n', '<C-s>', '<cmd>MarkdownPreview<CR>', 'Start Markdown preview')
map('n', '<M-s>', '<cmd>MarkdownPreviewStop<CR>', 'Stop Markdown preview')
map('n', '<C-p>', '<cmd>MarkdownPreviewToggle<CR>', 'Toggle Markdown preview')

-- Health Check --
vim.api.nvim_create_user_command('ConfigHealth', function()
  require('health').check()
end, {})
