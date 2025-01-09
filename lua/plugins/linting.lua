return {
  'mfussenegger/nvim-lint',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      json = { 'ansible-lint' },
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      svelte = { 'eslint_d' },
      python = { 'pylint' },
      bash = { 'shellcheck', 'shellharden' },
      c = { 'cpplint' },
      cpp = { 'cpplint' },
      text = { 'codespell' },
      html = { 'djlint' },
      go = { 'golangci-lint' },
      dockerfile = { 'hadolint' },
      markdown = { 'markdownlint' },
      json = { 'jsonlint' },
      yaml = { 'yamllint' },
      lua = { 'luacheck' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
    vim.keymap.set('n', '<C-l>', function()
      lint.try_lint()
    end, { desc = 'Trigger linting for current file' })
  end,
}
