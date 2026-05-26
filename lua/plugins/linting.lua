return {
  'mfussenegger/nvim-lint',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      -- Web / frontend
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      svelte = { 'eslint_d' },

      -- Python
      python = { 'pylint' },

      -- Shell
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
      zsh = { 'shellcheck' },

      -- C / C++
      c = { 'cpplint' },
      cpp = { 'cpplint' },

      -- Go
      go = { 'golangci-lint' },

      -- Docker
      dockerfile = { 'hadolint' },

      -- Data / config
      json = { 'jsonlint' },
      yaml = { 'yamllint' },

      -- Docs / prose
      markdown = { 'markdownlint' },
      text = { 'codespell' },

      -- Lua
      lua = { 'luacheck' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('nvim_lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
      if vim.opt_local.modifiable:get() then
        lint.try_lint()
      end
      end,
    })

    vim.keymap.set('n', '<leader>l', function()
      lint.try_lint()
    end, { desc = 'Trigger linting for current file' })
  end,
}
