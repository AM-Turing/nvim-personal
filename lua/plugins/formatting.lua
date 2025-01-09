return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require 'conform'

    conform.setup {
      formatters_by_ft = {
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
        svelte = { 'prettier' },
        css = { 'prettier' },
        html = { 'djlint' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'markdownlint' },
        graphql = { 'prettier' },
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        bash = { 'beautysh' },
        shell = { 'shellharden' },
        zsh = { 'beautysh' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        text = { 'codespell' },
        go = { 'gofmt' },
        csharp = { 'csharpier' },
        terraform = { 'terraform_fmt' },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      },
    }
    vim.keymap.set({ 'n', 'v' }, '<C-mp>', function()
      conform.format {
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      }
    end, { desc = 'Format file or range (in visual mode)' })
  end,
}
