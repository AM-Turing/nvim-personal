return {
  'jannis-baum/vivify.vim',
  ft = {
    'markdown',
  },
  init = function()
    -- Refresh the browser view while editing.
    vim.g.vivify_instant_refresh = 1

    -- Keep the browser view roughly synced with the cursor.
    vim.g.vivify_auto_scroll = 1

    -- Treat Markdown buffers as Vivify-compatible.
    vim.g.vivify_filetypes = {
      'markdown',
    }
  end,
}
