return {
  'nvimtools/none-ls.nvim',
  config = function()
    local null_ls = require 'null-ls'
    null_ls.setup ({
      sources = {
        -- formatting:
        -- lua
        null_ls.builtins.formatting.stylua,
        -- Python
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        -- C / C++
        null_ls.builtins.formatting.clang_format,
        -- Spell Checker
        null_ls.builtins.formatting.codespell,
        -- html
        null_ls.builtins.formatting.djlint,
        -- go
        null_ls.builtins.formatting.gofumpt,
        -- javascript
        null_ls.builtins.formatting.prettier,
        -- markdown
        null_ls.builtins.formatting.markdownlint,
        -- shell hardener
        null_ls.builtins.formatting.shellharden,
        -- bash
        null_ls.builtins.formatting.shfmt,
        -- yaml
        null_ls.builtins.formatting.yamlfix,
        -- Diagnostics:
        -- ansible
        null_ls.builtins.diagnostics.ansiblelint,
        -- C / C++
        null_ls.builtins.diagnostics.cppcheck,
        -- html
        null_ls.builtins.diagnostics.djlint,
        -- go
        null_ls.builtins.diagnostics.golangci_lint,
        -- docker
        null_ls.builtins.diagnostics.hadolint,
        -- markdown
        null_ls.builtins.diagnostics.markdownlint,
        -- python
        null_ls.builtins.diagnostics.pylint,
        -- json/yaml
        null_ls.builtins.diagnostics.spectral,
        -- javascript
        null_ls.builtins.diagnostics.eslint_d,
        -- Completion:
        -- spelling:
        null_ls.builtins.completion.spell,
        -- nvim
        null_ls.builtins.completion.luasnip,
        null_ls.builtins.completion.nvim_snippets,
      },
    })
  end,
}
