-- Tab settings for nvim
vim.cmd 'set expandtab'
vim.cmd 'set tabstop=2'
vim.cmd 'set softtabstop=2'
vim.cmd 'set shiftwidth=2'
--- Keymaps for Neo-Tree
vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>')
-- Keymaps for LSP options
vim.keymap.set('n', '<C-K>', vim.lsp.buf.hover, {})
vim.keymap.set('n', '<C-d>', vim.lsp.buf.definition, {})
vim.keymap.set({ 'n', 'v' }, '<C-a>', vim.lsp.buf.code_action, {})
vim.keymap.set('n', '<C-f>', vim.lsp.buf.format, {})
