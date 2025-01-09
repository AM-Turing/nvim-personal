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
-- Keymaps for Markdown preview
vim.api.nvim_create_autocmd('User', {
  pattern = 'MarkdownPreviewLoaded', -- Wait until the plugin is loaded
  callback = function()
    -- Keymaps for Markdown preview
    vim.keymap.set('n', '<C-s>', vim.cmd.MarkdownPreview) -- Start the preview
    vim.keymap.set('n', '<M-s>', vim.cmd.MarkdownPreviewStop) -- Stop the preview
    vim.keymap.set('n', '<C-p>', vim.cmd.MarkdownPreviewToggle) -- Toggle the preview
  end,
})
-- Keymaps for formatting (conform):
