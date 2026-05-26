-- Custom health checks for this Neovim configuration.
--
-- This file is not a Lazy plugin spec. Do not place it in lua/plugins/.
--
-- Recommended location:
--   ~/.config/nvim/lua/health.lua
--
-- How to use from inside Neovim:
--   :lua require('health').check()
--
-- Optional command mapping you can add later:
--   vim.api.nvim_create_user_command('ConfigHealth', function()
--     require('health').check()
--   end, {})

local M = {}

local function health_start(name)
  if vim.health.start then
    vim.health.start(name)
  else
    vim.health.report_start(name)
  end
end

local function health_ok(message)
  if vim.health.ok then
    vim.health.ok(message)
  else
    vim.health.report_ok(message)
  end
end

local function health_warn(message)
  if vim.health.warn then
    vim.health.warn(message)
  else
    vim.health.report_warn(message)
  end
end

local function health_error(message)
  if vim.health.error then
    vim.health.error(message)
  else
    vim.health.report_error(message)
  end
end

local function health_info(message)
  if vim.health.info then
    vim.health.info(message)
  else
    vim.health.report_info(message)
  end
end

local function executable_exists(exe)
  return vim.fn.executable(exe) == 1
end

local function path_exists(path)
  return (vim.uv or vim.loop).fs_stat(vim.fn.expand(path)) ~= nil
end

local function check_executable(exe, required, note)
  if executable_exists(exe) then
    health_ok(("Found executable: %s"):format(exe))
  elseif required then
    health_error(("Missing required executable: %s%s"):format(exe, note and (" - " .. note) or ""))
  else
    health_warn(("Missing optional executable: %s%s"):format(exe, note and (" - " .. note) or ""))
  end
end

local function check_path(path, required, note)
  local expanded = vim.fn.expand(path)

  if path_exists(path) then
    health_ok(("Found path: %s"):format(expanded))
  elseif required then
    health_error(("Missing required path: %s%s"):format(expanded, note and (" - " .. note) or ""))
  else
    health_warn(("Missing optional path: %s%s"):format(expanded, note and (" - " .. note) or ""))
  end
end

local function check_neovim_version()
  local version = vim.version()
  local version_string = tostring(version)

  if vim.version.ge and vim.version.ge(version, '0.10.0') then
    health_ok(("Neovim version is supported: %s"):format(version_string))
  else
    health_error(("Neovim version may be too old: %s. Use Neovim 0.10+ if possible."):format(version_string))
  end
end

local function check_leader_keys()
  if vim.g.mapleader == ' ' then
    health_ok "Leader key is set to Space"
  else
    health_warn ("Leader key is not Space. Current value: %s"):format(vim.inspect(vim.g.mapleader))
  end

  if vim.g.maplocalleader == ' ' then
    health_ok "Local leader key is set to Space"
  else
    health_warn ("Local leader key is not Space. Current value: %s"):format(vim.inspect(vim.g.maplocalleader))
  end
end

local function check_python_provider()
  local expected_python = '~/.local/share/nvim/python/venv/bin/python'
  local configured_python = vim.g.python3_host_prog

  check_path(expected_python, true, 'Create this venv for Neovim Python provider support')

  if configured_python == nil or configured_python == '' then
    health_error 'vim.g.python3_host_prog is not set'
    return
  end

  local expanded_configured_python = vim.fn.expand(configured_python)

  if path_exists(configured_python) then
    health_ok(('Configured Python provider exists: %s'):format(expanded_configured_python))
  else
    health_error(('Configured Python provider does not exist: %s'):format(expanded_configured_python))
  end

  local pynvim_check = vim.fn.system {
    expanded_configured_python,
    '-c',
    'import pynvim; print(pynvim.__version__)',
  }

  if vim.v.shell_error == 0 then
    health_ok(('pynvim is installed in the Neovim provider venv: %s'):format(vim.trim(pynvim_check)))
  else
    health_error 'pynvim is not installed in the configured Neovim Python provider venv'
  end
end

local function check_core_tools()
  health_start 'Core external tools'

  check_executable('git', true, 'Required by lazy.nvim and plugin installs')
  check_executable('curl', true, 'Used by many installers and tooling workflows')
  check_executable('unzip', true, 'Required by some Mason tools and plugin installs')
  check_executable('tar', true, 'Required by Treesitter/Mason tool installs')
  check_executable('make', true, 'Required for native builds and Treesitter parsers')
  check_executable('gcc', true, 'Required for Treesitter parser compilation')
  check_executable('rg', true, 'Required for Telescope live_grep')

  if executable_exists('fd') then
    health_ok 'Found executable: fd'
  elseif executable_exists('fdfind') then
    health_warn 'Found fdfind but not fd. On Debian, create a symlink from fdfind to ~/.local/bin/fd for Telescope.'
  else
    health_warn 'Missing fd/fdfind. Install fd-find for faster Telescope file search.'
  end
end

local function check_language_runtimes()
  health_start 'Language runtimes'

  check_executable('python3', true, 'Required for Python tooling and provider venv creation')
  check_executable('node', true, 'Required for many LSP servers and Markdown Preview')
  check_executable('npm', true, 'Required for Node-based LSP servers and formatters')
  check_executable('yarn', false, 'Required by markdown-preview.nvim install flow')
  check_executable('ruby', false, 'Required for Ruby/Solargraph support')
  check_executable('java', false, 'Required for Java/jdtls support')
  check_executable('go', false, 'Required for Go/gopls support')
  check_executable('rustc', false, 'Required for Rust tooling')
  check_executable('cargo', false, 'Required for Rust-installed tools like stylua if installed through cargo')
end

local function check_formatters()
  health_start 'Formatters'

  check_executable('stylua', false, 'Lua formatting')
  check_executable('black', false, 'Python formatting')
  check_executable('isort', false, 'Python import sorting')
  check_executable('prettier', false, 'Web, JSON, YAML, Markdown formatting')
  check_executable('shfmt', false, 'Shell formatting')
  check_executable('clang-format', false, 'C/C++ formatting')
  check_executable('gofmt', false, 'Go formatting')
  check_executable('terraform', false, 'Terraform formatting through terraform fmt')
end

local function check_linters()
  health_start 'Linters'

  check_executable('pylint', false, 'Python linting')
  check_executable('ruff', false, 'Optional Python linting/tooling')
  check_executable('eslint_d', false, 'JavaScript/TypeScript linting')
  check_executable('shellcheck', false, 'Shell linting')
  check_executable('cpplint', false, 'C/C++ linting')
  check_executable('golangci-lint', false, 'Go linting')
  check_executable('hadolint', false, 'Dockerfile linting')
  check_executable('jsonlint', false, 'JSON linting')
  check_executable('yamllint', false, 'YAML linting')
  check_executable('markdownlint', false, 'Markdown linting')
  check_executable('luacheck', false, 'Lua linting')
  check_executable('codespell', false, 'Text/code spelling linting')
end

local function check_neovim_paths()
  health_start 'Neovim config paths'

  check_path('~/.config/nvim/init.lua', true, 'Main Neovim entrypoint')
  check_path('~/.config/nvim/lua/vim-options.lua', true, 'General editor options')
  check_path('~/.config/nvim/lua/plugins', true, 'Primary plugin spec directory')
  check_path('~/.config/nvim/lazy-lock.json', false, 'Plugin lockfile for reproducible installs')
end

local function check_loaded_plugins()
  health_start 'Loaded plugin modules'

  local modules = {
    { name = 'lazy', required = true, note = 'Plugin manager' },
    { name = 'mason', required = false, note = 'External tool manager' },
    { name = 'mason-lspconfig', required = false, note = 'Mason/LSP bridge' },
    { name = 'lspconfig', required = false, note = 'LSP server configuration' },
    { name = 'cmp', required = false, note = 'Completion engine' },
    { name = 'luasnip', required = false, note = 'Snippet engine' },
    { name = 'conform', required = false, note = 'Formatter integration' },
    { name = 'lint', required = false, note = 'Linter integration' },
    { name = 'telescope', required = false, note = 'Fuzzy finder' },
    { name = 'neo-tree', required = false, note = 'File tree' },
    { name = 'nvim-treesitter.configs', required = false, note = 'Treesitter config' },
    { name = 'lualine', required = false, note = 'Statusline' },
    { name = 'nightfox', required = false, note = 'Colorscheme' },
  }

  for _, module in ipairs(modules) do
    local ok = pcall(require, module.name)

    if ok then
      health_ok(('Loaded module: %s'):format(module.name))
    elseif module.required then
      health_error(('Could not load required module: %s - %s'):format(module.name, module.note))
    else
      health_warn(('Could not load optional module: %s - %s'):format(module.name, module.note))
    end
  end
end

function M.check()
  health_start 'Custom Neovim environment'

  health_info [[This health check is tailored for this Debian-based Neovim setup.

Warnings are not always failures. Prioritize:
  1. Neovim version
  2. git/curl/unzip/make/gcc/rg/fd
  3. Python provider venv + pynvim
  4. Tools for languages you actually use]]

  local uv = vim.uv or vim.loop
  health_info('System information: ' .. vim.inspect(uv.os_uname()))

  check_neovim_version()
  check_leader_keys()
  check_neovim_paths()
  check_python_provider()
  check_core_tools()
  check_language_runtimes()
  check_formatters()
  check_linters()
  check_loaded_plugins()
end

return M
