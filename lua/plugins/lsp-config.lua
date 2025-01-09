return {
  {
    'williamboman/mason.nvim',
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      local mason_tool_installer = require("mason-tool-installer")
      require('mason').setup({
        ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
          "cpplint",
          "codespell", -- text
          "ansible-lint", -- yaml but for ansible
          "beautysh", -- bash, zsh
          "black", -- python
          "clang-format", -- c/c++
          "clangd", -- c / c++
          "djlint", -- html / django 
          "eslint_d", -- js
          "glint", -- go
          "gofumpt", -- go
          "golangci-lint", -- go
          "hadolint", -- dockerfiles
          "jsonlint", -- json
          "luacheck", -- lua
          "markdownlint", -- markdown
          "prettier", -- js and more 
          "pylint", -- python
          "shellcheck", -- bash, sh
          "shellharden", -- bash, sh
          "shfmt", -- bash, sh
          "stylua", -- lua
          "yamllint", -- yaml
        },
      })
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { "ansiblels", "bashls", "clangd", "cssls", "dockerls", "gopls", "html", "intelephense", "jdtls", "jsonls", "lua_ls", "markdown_oxide", "pyright", "rust_analyzer", "solargraph", "terraformls", "ts_ls", "yamlls", "zls" }
      })
    end
  },
  {
    -- Setup lsp server language support
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      lspconfig.ansiblels.setup({})
      lspconfig.bashls.setup({})
      -- C & C++ below
      lspconfig.clangd.setup({})
      lspconfig.cssls.setup({})
      lspconfig.dockerls.setup({})
      lspconfig.gopls.setup({})
      lspconfig.html.setup({})
      -- PHP below
      lspconfig.intelephense.setup({
        settings = {
          intelephense = {
            filetypes = { "php", "html", "css", "javascript" },
          },
        },
      })
      -- Java below
      lspconfig.jdtls.setup({
        cmd = { "java-ls" },
      })
      lspconfig.jsonls.setup({})
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      })
      lspconfig.markdown_oxide.setup({})
      -- Python below
      lspconfig.pyright.setup({})
      lspconfig.rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            diagnostics = {
              enable = true;
            },
          },
        },
      })
      -- Ruby below
      lspconfig.solargraph.setup({
        settings = {
          solargraph = {
            diagnostics = true,
          },
        },
      })
      lspconfig.terraformls.setup({})
      -- Javascript & Typescript below
      lspconfig.ts_ls.setup({
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      })
      lspconfig.yamlls.setup({
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*",
            },
          },
        },
      })
      -- Zig below
      lspconfig.zls.setup({})
    end
  }
}
-- ctrl shift + :h vim.lsp.buff - shows options for lsp interaction to use for key mapping
