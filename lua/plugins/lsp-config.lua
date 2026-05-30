return {
  -- Mason package manager.
  {
    'williamboman/mason.nvim',
    dependencies = {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      require('mason').setup {
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      }

      require('mason-tool-installer').setup {
        ensure_installed = {
          -- General / docs
          'codespell',
          'markdownlint',
          'prettier',

          -- Web / frontend
          'eslint_d',

          -- Python
          'black',
          'isort',
          'pylint',
          'ruff',

          -- Lua
          'luacheck',
          'stylua',

          -- Shell
          'shellcheck',
          'shfmt',

          -- C / C++
          'clang-format',
          'clangd',
          'cpplint',

          -- Go
          'gofumpt',
          'golangci-lint',
          'gopls',

          -- Docker
          'hadolint',

          -- Data / config
          'jsonlint',
          'yamllint',

          -- Terraform
          'terraformls',
        },
      }
    end,
  },

  -- Mason bridge for LSP servers.
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'ansiblels',
          'bashls',
          'clangd',
          'cssls',
          'dockerls',
          'gopls',
          'html',
          'intelephense',
          'jdtls',
          'jsonls',
          'lua_ls',
          'markdown_oxide',
          'pyright',
          'rust_analyzer',
          'solargraph',
          'terraformls',
          'ts_ls',
          'yamlls',
          'zls',
        },
      }
    end,
  },

  -- Neovim LSP configuration.
  --
  -- Neovim 0.11+ deprecates the old:
  --   require('lspconfig').SERVER.setup(...)
  -- pattern.
  --
  -- Keep nvim-lspconfig installed because it still provides server defaults,
  -- but use Neovim's native vim.lsp.config() and vim.lsp.enable() APIs.
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    lazy = false,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local servers = {
        ansiblels = {},
        bashls = {},
        clangd = {},
        cssls = {},
        dockerls = {},
        gopls = {},
        html = {},
        jsonls = {},
        markdown_oxide = {},
        pyright = {},
        terraformls = {},
        zls = {},

        intelephense = {
          settings = {
            intelephense = {
              filetypes = { 'php', 'html', 'css', 'javascript' },
            },
          },
        },

        jdtls = {
          -- Mason's jdtls package normally provides the correct command.
          -- Override this only if you intentionally use a custom Java LSP command.
          -- cmd = { 'java-ls' },
        },

        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },

        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              diagnostics = {
                enable = true,
              },
            },
          },
        },

        solargraph = {
          settings = {
            solargraph = {
              diagnostics = true,
            },
          },
        },

        ts_ls = {
          filetypes = {
            'typescript',
            'typescriptreact',
            'javascript',
            'javascriptreact',
          },
        },

        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*',
              },
            },
          },
        },
      }

      for server_name, server_config in pairs(servers) do
        server_config.capabilities = capabilities

        vim.lsp.config(server_name, server_config)
        vim.lsp.enable(server_name)
      end
    end,
  },
}

-- LSP help:
--   :help vim.lsp.buf
--   :help vim.lsp.config
--   :help vim.lsp.enable
--
-- Useful commands:
--   :LspInfo
--   :Mason
--   :checkhealth lsp
