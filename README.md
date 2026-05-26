# Neovim VM Setup Guide

This README documents this refactored Neovim configuration, how to install it on a fresh Debian-based VM, how to update an existing Neovim instance that already uses this layout, and how to maintain the major components. This README was created by ChatGPT. Yes, I am lazy. Sorry, not sorry.

<b>Use the `bootstrap.sh` to build out this config.</b> Instructions and details are below. 

<b>Hotkeys are summarized in HOTKEYS.md</b>


The configuration is based on a cleaned-up fork of Kickstart.nvim, but the active layout has been simplified so that all active plugin specs live in one directory:

```text
~/.config/nvim/lua/plugins/
```

---

## 1. Final Directory Structure

Expected layout:

```text
.
├── doc
│   ├── kickstart.txt
│   └── tags
├── init.lua
├── lazy-lock.json
├── LICENSE.md
├── lua
│   ├── health.lua
│   ├── plugins
│   │   ├── autopairs.lua
│   │   ├── completions.lua
│   │   ├── dashboard.lua
│   │   ├── debug.lua
│   │   ├── formatting.lua
│   │   ├── gitsigns.lua
│   │   ├── indent_line.lua
│   │   ├── linting.lua
│   │   ├── lsp-config.lua
│   │   ├── lualine.lua
│   │   ├── vivify.lua
│   │   ├── neotree.lua
│   │   ├── nightfox.lua
│   │   ├── telescope.lua
│   │   └── treesitter.lua
│   └── vim-options.lua
└── README.md
```

The active plugin import should be:

```lua
require('lazy').setup {
  { import = 'plugins' },
}
```

---

## 2. File Ownership Model

Use this model to decide where future changes belong.

```text
init.lua
  Bootstrap lazy.nvim
  Set leader key
  Set Python provider
  Import plugin specs
  Load vim-options.lua

lua/vim-options.lua
  General editor options
  General keymaps
  Custom user commands such as :ConfigHealth

lua/health.lua
  Custom environment health checks
  Not a Lazy plugin
  Do not place in lua/plugins/

lua/plugins/completions.lua
  nvim-cmp
  LuaSnip
  Completion sources
  Snippet integration

lua/plugins/formatting.lua
  conform.nvim
  Formatters by filetype
  Format-on-save
  Manual format keymap

lua/plugins/linting.lua
  nvim-lint
  Linters by filetype
  Automatic linting
  Manual lint keymap

lua/plugins/lsp-config.lua
  Mason
  Mason Tool Installer
  Mason LSPConfig
  nvim-lspconfig server setup

lua/plugins/treesitter.lua
  Treesitter parsers
  Syntax highlighting
  Indentation
  Textobjects

lua/plugins/telescope.lua
  Telescope setup
  Telescope extensions
  Telescope keymaps

lua/plugins/neotree.lua
  Neo-tree behavior
  File tree mappings

lua/plugins/debug.lua
  nvim-dap
  nvim-dap-ui
  Go debugging
  Python debugging

lua/plugins/gitsigns.lua
  Git gutter signs
  Git hunk actions
  Git blame/diff toggles

lua/plugins/autopairs.lua
  Automatic bracket/quote pairing
  nvim-cmp autopairs integration

lua/plugins/indent_line.lua
  Indentation guides

lua/plugins/nightfox.lua
  Colorscheme

lua/plugins/lualine.lua
  Statusline

lua/plugins/vivify.lua
  Markdown preview behavior

lua/plugins/dashboard.lua
  Alpha dashboard
```

---

## 3. Current `init.lua` Requirements

The `init.lua` should set the leader key before plugins load.

Expected structure:

```lua
-- Leader keys must be set before lazy.nvim loads plugin keymaps.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Dedicated Debian-safe Python provider venv.
vim.g.python3_host_prog = vim.fn.expand '~/.local/share/nvim/python/venv/bin/python'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})

    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  { import = 'plugins' },
}

require 'vim-options'
```

---

## 4. Fresh Debian VM Setup

Note: `bootstrap.sh` will do this for you, but this is informational in case it messes up. 

Run this first on a fresh Debian/Ubuntu VM.

```bash
sudo apt update

sudo apt install -y \
  git \
  curl \
  wget \
  unzip \
  tar \
  gzip \
  xz-utils \
  ca-certificates \
  gnupg \
  software-properties-common \
  build-essential \
  gcc \
  g++ \
  make \
  cmake \
  pkg-config \
  ripgrep \
  fd-find \
  jq \
  tree \
  xclip \
  wl-clipboard \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  nodejs \
  npm \
  lua5.1 \
  liblua5.1-0-dev \
  libreadline-dev \
  luarocks \
  ruby-full \
  openjdk-17-jdk \
  clangd \
  shellcheck \
  codespell
```

### Fix `fd` on Debian/Ubuntu

Note: `bootstrap.sh` will do this for you, but this is informational in case it messes up. 

Debian usually installs `fd` as `fdfind`. 

```bash
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

Verify:

```bash
which fd
fd --version
```

---

## 5. Bashrc / PATH Setup

Note: `bootstrap.sh` will do this for you, but this is informational in case it messes up. 

Use clean directory-based PATH entries.

Recommended `~/.bashrc` additions:

```bash
# User-local executables
export PATH="$HOME/.local/bin:$PATH"

# Rust / Cargo environment
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Optional local environment file
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# Go toolchain
export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
```

Do **not** add executable files directly to `PATH`.

Verify after editing:

```bash
source ~/.bashrc

echo "$PATH" | tr ':' '\n'

which npm
which node
which go
which gopls
which cargo
which stylua
which fd
```

Expected examples:

```text
npm      -> /usr/bin/npm
node     -> /usr/bin/node
go       -> /usr/local/go/bin/go
gopls    -> $HOME/go/bin/gopls
cargo    -> $HOME/.cargo/bin/cargo
stylua   -> $HOME/.cargo/bin/stylua or Mason-managed path
fd       -> $HOME/.local/bin/fd
```

---

---

## Modern Neovim Requirement

Note: `bootstrap.sh` will do this for you, but this is informational in case it messes up. 

This configuration uses `lazy.nvim`, which requires a newer Neovim than the version shipped by some Debian releases.

A common failure looks like this:

```text
Error detected while processing /home/dev1/.config/nvim/init.lua:
lazy.nvim requires Neovim >= 0.8.0
```

If `nvim --version` shows something old, such as:

```text
NVIM v0.7.2
```

then the config is not the problem. The Neovim binary is too old.

The bootstrap script installs a modern official Neovim release into:

```text
~/tools/neovim/nvim-linux-x86_64/
```

and symlinks it to:

```text
~/.local/bin/nvim
```

After running the bootstrap script, reload your shell and confirm the right binary is first in PATH:

```bash
source ~/.bashrc
hash -r

which nvim
nvim --version
```

Expected path:

```text
/home/dev1/.local/bin/nvim
```

If `which nvim` still shows:

```text
/usr/bin/nvim
```

then your shell is still using the old Debian package. Confirm `~/.local/bin` appears before `/usr/bin`:

```bash
echo "$PATH" | tr ':' '\n'
```

Manual recovery:

```bash
mkdir -p ~/tools/neovim
cd ~/tools/neovim

curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

rm -rf nvim-linux-x86_64
tar xzf nvim-linux-x86_64.tar.gz

mkdir -p ~/.local/bin
ln -sf "$HOME/tools/neovim/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"

source ~/.bashrc
hash -r

which nvim
nvim --version
```

Then rerun plugin setup:

```bash
nvim --headless "+Lazy sync" +qa
```

---

---

## Nerd Font / Terminal Font Setup

This configuration uses glyphs and icons from plugins such as:

```text
nvim-web-devicons
neo-tree.nvim
alpha-nvim
lualine.nvim
```

For those symbols to render correctly, the terminal must use a Nerd Font.

The bootstrap script installs JetBrainsMono Nerd Font into:

```text
~/.local/share/fonts/JetBrainsMonoNerdFont/
```

It downloads the font archive from:

```text
https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
```

and refreshes the user font cache with:

```bash
fc-cache -fv ~/.local/share/fonts
```

Verify the font is installed:

```bash
fc-list | grep -i "JetBrains.*Nerd"
```

### GNOME Terminal Manual Step

Installing the font files is not enough. GNOME Terminal must be told to use the Nerd Font.

Open:

```text
GNOME Terminal → Preferences → your active profile → Text
```

Then:

```text
Enable Custom font
Select JetBrainsMono Nerd Font or JetBrainsMono Nerd Font Mono
Close and reopen the terminal
```

If icons look like boxes, random symbols, or broken characters, the terminal profile is probably not using the Nerd Font yet.

### Bootstrap skip flag

To skip Nerd Font installation:

```bash
./bootstrap.sh --skip-nerd-font-install
```

## Vivify Markdown Preview Setup

This config uses Vivify for Markdown/browser preview.

Vivify consists of two binaries:

```text
viv
vivify-server
```

For this setup, both should be installed into:

```text
~/.local/bin/
```

The bootstrap script installs Vivify automatically from:

```text
https://github.com/jannis-baum/Vivify/releases/download/v0.14.0/vivify-linux.tar.gz
```

Manual install:

```bash
mkdir -p ~/tools/vivify ~/.local/bin
cd ~/tools/vivify

curl -fLO https://github.com/jannis-baum/Vivify/releases/download/v0.14.0/vivify-linux.tar.gz

rm -rf extracted
mkdir -p extracted

tar xzf vivify-linux.tar.gz -C extracted

find extracted -type f -name viv -exec install -m 0755 {} ~/.local/bin/viv \;
find extracted -type f -name vivify-server -exec install -m 0755 {} ~/.local/bin/vivify-server \;
```

Verify:

```bash
which viv
which vivify-server
viv --help
vivify-server --help
```

Neovim plugin:

```text
lua/plugins/vivify.lua
```

Keymap:

```text
<leader>mp = Open current Markdown buffer in Vivify
```

Command:

```vim
:Vivify
```

Test:

```bash
nvim README.md
```

Inside Neovim:

```vim
:set filetype?
:Vivify
:messages
```

Expected filetype:

```text
filetype=markdown
```

## 6. Python Provider Setup for Debian

Debian 12+ uses an externally managed system Python environment. Do not use:

```bash
python3 -m pip install --user pynvim
```

Instead, create a dedicated Neovim Python provider venv:

```bash
sudo apt install -y python3-venv python3-pip

mkdir -p ~/.local/share/nvim/python
python3 -m venv ~/.local/share/nvim/python/venv

~/.local/share/nvim/python/venv/bin/python -m pip install --upgrade pip
~/.local/share/nvim/python/venv/bin/python -m pip install --upgrade \
  pynvim \
  debugpy \
  ruff \
  black \
  isort \
  mypy
```

Your `init.lua` should point Neovim to this interpreter:

```lua
vim.g.python3_host_prog = vim.fn.expand '~/.local/share/nvim/python/venv/bin/python'
```

Verify:

```bash
~/.local/share/nvim/python/venv/bin/python -m pip list
```

Inside Neovim:

```vim
:checkhealth provider
```

---

## 7. Optional Language Runtime Setup

### Rust and Stylua

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
cargo install stylua
```

### Go

Download the current Linux AMD64 tarball from the official Go downloads page.

Then:

```bash
cd ~/Downloads

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go*.linux-amd64.tar.gz

echo 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

go version
go install golang.org/x/tools/gopls@latest
```

### Node / NPM Tools

```bash
sudo npm install -g \
  dockerfile-language-server-nodejs \
  pyright \
  typescript \
  typescript-language-server \
  bash-language-server \
  vscode-langservers-extracted \
  yaml-language-server \
  markdownlint-cli \
  prettier \
  yarn
```

### Ruby

```bash
sudo gem install bundler ruby-lsp
```

---

## 8. Install This Config on a Fresh VM

Back up any existing Neovim config:

```bash
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
```

Clone your fork:

```bash
git clone <YOUR_FORK_URL> ~/.config/nvim
```

Or copy this directory into place:

```bash
mkdir -p ~/.config
cp -a /path/to/this/config ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

Then run:

```vim
:Lazy restore
:Lazy sync
:Mason
:ConfigHealth
:checkhealth
```

Restart Neovim:

```vim
:qa
```

```bash
nvim
```

---

---

## Bootstrap Script Usage

This repository includes a top-level bootstrap script:

```text
bootstrap.sh
```

The script is intended to automate setup on a fresh Debian/Ubuntu-based VM or update an existing Neovim environment to this refactored configuration.

Repository sources used by the bootstrap script:

```text
SSH:   git@github.com:AM-Turing/nvim-personal.git
HTTPS: https://github.com/AM-Turing/nvim-personal.git
```

---

### What the Bootstrap Script Does

The script performs the following tasks:

```text
Checks for an existing ~/.config/nvim
Prompts the user to replace, upgrade in place, or skip if an existing config is found
Clones this repo from GitHub using SSH or HTTPS
Installs Debian/Ubuntu apt dependencies
Installs a modern official Neovim release into ~/tools/neovim
Symlinks the modern nvim binary into ~/.local/bin/nvim
Downloads Vivify v0.14.0 and installs viv/vivify-server into ~/.local/bin
Installs JetBrainsMono Nerd Font into ~/.local/share/fonts
Creates/updates shell PATH helpers in ~/.bashrc
Creates the Debian-safe Neovim Python provider venv
Installs Python tooling into the Neovim provider venv
Installs common Node/NPM tooling
Installs Rust/stylua when enabled
Installs Go gopls when Go is present
Installs Ruby tooling when enabled
Runs Lazy sync
Runs Treesitter update
Runs ConfigHealth/checkhealth validation
```

---

### First-Time Use on a Fresh VM

On a fresh VM, download or clone the repository first.

Using HTTPS:

```bash
git clone https://github.com/AM-Turing/nvim-personal.git
cd nvim-personal
```

Using SSH:

```bash
git clone git@github.com:AM-Turing/nvim-personal.git
cd nvim-personal
```

Then run:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

If no existing Neovim config exists at:

```text
~/.config/nvim
```

the script will clone the GitHub project and install it as the active Neovim configuration.

---

### Existing Neovim Setup Behavior

If the script detects an existing config at:

```text
~/.config/nvim
```

it prompts for one of three choices:

```text
1) backup-replace
   Back up the existing config, then replace it with a fresh clone.

2) upgrade-in-place
   Back up the existing config, then copy the new repo over the existing config.
   This can preserve extra local files, but old unused files may remain.

3) skip
   Leave the existing Neovim config unchanged.
```

Recommended choice for most migrations:

```text
backup-replace
```

Recommended choice if you have local files you know you want to preserve:

```text
upgrade-in-place
```

The script creates timestamped backups before replacing or upgrading.

Example backup path:

```text
~/.config/nvim.backup.20260525-213000
```

---

### Clone Mode: SSH vs HTTPS

By default, the script tries to detect whether GitHub SSH authentication is available.

If SSH appears available, it offers to use:

```text
git@github.com:AM-Turing/nvim-personal.git
```

Otherwise, it uses HTTPS:

```text
https://github.com/AM-Turing/nvim-personal.git
```

Force HTTPS:

```bash
./bootstrap.sh --repo-mode https
```

Force SSH:

```bash
./bootstrap.sh --repo-mode ssh
```

---

### Non-Interactive Examples

Use defaults where possible:

```bash
./bootstrap.sh --yes
```

Fresh install or automated setup using HTTPS:

```bash
./bootstrap.sh --yes --repo-mode https
```

Existing config: back up and replace with a fresh clone:

```bash
./bootstrap.sh --repo-mode https --existing-mode backup-replace
```

Existing config: back up and upgrade in place:

```bash
./bootstrap.sh --repo-mode https --existing-mode upgrade-in-place
```

Skip validation commands:

```bash
./bootstrap.sh --skip-validation
```

---

### Optional Skip Flags

Use these when you want a smaller or faster setup.

```bash
./bootstrap.sh --skip-apt
./bootstrap.sh --skip-neovim-install
./bootstrap.sh --skip-vivify-install
./bootstrap.sh --skip-node-globals
./bootstrap.sh --skip-rust
./bootstrap.sh --skip-go
./bootstrap.sh --skip-gem
./bootstrap.sh --skip-validation
```

Flag meanings:

| Flag | Meaning |
|---|---|
| `--skip-apt` | Do not install apt packages |
| `--skip-neovim-install` | Do not install the official modern Neovim release tarball |
| `--skip-vivify-install` | Do not install Vivify Markdown preview binaries |
| `--skip-node-globals` | Do not install global npm tools |
| `--skip-rust` | Do not install Rust/stylua through cargo |
| `--skip-go` | Do not install Go tools such as `gopls` |
| `--skip-gem` | Do not install Ruby gems |
| `--skip-validation` | Do not run headless Neovim validation commands |

---

### Bootstrap-Managed Python Provider

The bootstrap script creates this dedicated Neovim Python provider venv:

```text
~/.local/share/nvim/python/venv
```

It installs:

```text
pynvim
debugpy
ruff
black
isort
mypy
```

This avoids Debian externally-managed Python issues and matches the `init.lua` setting:

```lua
vim.g.python3_host_prog = vim.fn.expand '~/.local/share/nvim/python/venv/bin/python'
```

---

### Bootstrap-Managed Bashrc Block

The script adds a managed block to:

```text
~/.bashrc
```

The block is marked with:

```bash
# >>> nvim-personal bootstrap >>>
...
# <<< nvim-personal bootstrap <<<
```

It adds clean PATH support for:

```text
~/.local/bin
~/.cargo/env
~/.local/bin/env
/usr/local/go/bin
~/go/bin
```

It does **not** add `/usr/bin/npm` to PATH because PATH entries must be directories.

---

### Post-Bootstrap Validation

After the script finishes, reload the shell environment:

```bash
source ~/.bashrc
```

Then open Neovim:

```bash
nvim
```

Inside Neovim, run:

```vim
:ConfigHealth
:checkhealth
:Lazy
:Mason
:LspInfo
:TSInstallInfo
```

Useful shell checks:

```bash
which nvim
which git
which rg
which fd
which node
which npm
which python3
which go
which gopls
which cargo
which stylua
```

Core keymaps to test:

```text
Ctrl-p      Telescope find files
Ctrl-g      Telescope live grep
Ctrl-n      Neo-tree reveal current file
Space f     Format current file/range
Space l     Lint current file
Space d b   Toggle debug breakpoint
Space g s   Git stage hunk
```

---

### Bootstrap Troubleshooting

If the script cannot clone with SSH, rerun with HTTPS:

```bash
./bootstrap.sh --repo-mode https
```

If apt package installation fails, rerun after fixing apt:

```bash
sudo apt update
sudo apt --fix-broken install
./bootstrap.sh
```

If Neovim validation fails, open Neovim manually and inspect:

```vim
:messages
:Lazy
:checkhealth
:ConfigHealth
```

If Vivify fails after bootstrap:

```bash
cd ~/.local/share/nvim/lazy/vivify.vim
yarn install
```

If `fd` is missing on Debian:

```bash
sudo apt install -y fd-find
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

If the Python provider check fails:

```bash
ls ~/.local/share/nvim/python/venv/bin/python
~/.local/share/nvim/python/venv/bin/python -m pip show pynvim
```

## 9. Updating an Existing Neovim Instance to This Refactored System

Use this section when a VM already has the old Kickstart-style config and you want to migrate it to the refactored structure.

### 9.1 Back up the existing config

```bash
cp -a ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d-%H%M%S)
```

Optional backup of data/cache directories:

```bash
cp -a ~/.local/share/nvim ~/.local/share/nvim.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
cp -a ~/.cache/nvim ~/.cache/nvim.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
```

### 9.2 Confirm the desired active structure

The active structure should be:

```text
~/.config/nvim/init.lua
~/.config/nvim/lua/health.lua
~/.config/nvim/lua/vim-options.lua
~/.config/nvim/lua/plugins/*.lua
```

Remove old active plugin directories once everything has been migrated:

```bash
rm -rf ~/.config/nvim/lua/kickstart
rm -rf ~/.config/nvim/lua/custom
```

Only do this after confirming the useful files have been migrated.

### 9.3 Confirm `init.lua` only imports the active plugin directory

Check:

```bash
grep -R "import =" ~/.config/nvim/init.lua
```

Expected:

```lua
{ import = 'plugins' },
```

Not expected:

```lua
{ import = 'kickstart.plugins' },
{ import = 'custom.plugins' },
```

### 9.4 Reset or resync plugins

To use versions pinned by `lazy-lock.json`:

```vim
:Lazy restore
```

To install/sync everything currently declared:

```vim
:Lazy sync
```

To update plugins to newer versions:

```vim
:Lazy update
```

After changing plugin files, restart Neovim:

```vim
:qa
```

```bash
nvim
```

### 9.5 Validate the migrated instance

Run:

```vim
:ConfigHealth
:checkhealth
:Lazy
:Mason
:LspInfo
:TSInstallInfo
```

From shell:

```bash
nvim --headless "+Lazy sync" +qa
```

If Treesitter changed:

```bash
nvim --headless "+TSUpdate" +qa
```

---

## 10. Plugin Summary

| File | Plugin / Purpose |
|---|---|
| `autopairs.lua` | `nvim-autopairs`; automatic bracket/quote pairing |
| `completions.lua` | `nvim-cmp`, `LuaSnip`, completion sources |
| `dashboard.lua` | `alpha-nvim` dashboard |
| `debug.lua` | `nvim-dap`, `dap-ui`, Go/Python debugging |
| `formatting.lua` | `conform.nvim` formatting |
| `gitsigns.lua` | Git signs and hunk actions |
| `indent_line.lua` | Indentation guides |
| `linting.lua` | `nvim-lint` linting |
| `lsp-config.lua` | Mason and LSP setup |
| `lualine.lua` | Statusline |
| `vivify.lua` | Vivify Markdown/browser preview |
| `neotree.lua` | File tree |
| `nightfox.lua` | Colorscheme |
| `telescope.lua` | Fuzzy finding |
| `treesitter.lua` | Syntax parsing, highlighting, textobjects |

---

## 11. Hotkey Quick Reference

This setup uses Space as leader:

```text
<leader> = Space
```

So:

```text
<leader>f = Space, then f
```

Leader mappings are normal-mode mappings unless otherwise stated. They do not trigger while typing text in insert mode.

---

### General / LSP

Defined in:

```text
lua/vim-options.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<C-n>` | Normal | Reveal current file in Neo-tree |
| `<C-k>` | Normal | Show LSP hover documentation |
| `<C-d>` | Normal | Go to LSP definition |
| `<C-a>` | Normal / Visual | Show LSP code actions |

Formatting should be handled by `formatting.lua` / conform.nvim, not by raw `vim.lsp.buf.format()` in `vim-options.lua`.

---

### Config Health

Defined through `lua/health.lua` and a user command in `vim-options.lua`.

| Command | Action |
|---|---|
| `:ConfigHealth` | Run custom config health check |
| `:lua require('health').check()` | Run custom config health check manually |

No default hotkey is assigned.

---

### Formatting

Defined in:

```text
lua/plugins/formatting.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<leader>f` | Normal / Visual | Format current file or selected range with conform.nvim |

Format-on-save is enabled.

Common formatter mapping:

| Filetype | Formatter |
|---|---|
| Python | `isort`, then `black` |
| Lua | `stylua` |
| Shell | `shfmt` |
| JavaScript / TypeScript | `prettier` |
| HTML / CSS / JSON / YAML / Markdown | `prettier` |
| C / C++ | `clang-format` |
| Go | `gofmt` |
| Terraform | `terraform_fmt` |

---

### Linting

Defined in:

```text
lua/plugins/linting.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<leader>l` | Normal | Trigger linting for current file |

Automatic linting runs on:

```text
BufEnter
BufWritePost
InsertLeave
```

The automatic lint callback should only run in modifiable buffers:

```lua
if vim.opt_local.modifiable:get() then
  lint.try_lint()
end
```

Common linter mapping:

| Filetype | Linter |
|---|---|
| Python | `pylint` |
| Shell | `shellcheck` |
| JavaScript / TypeScript | `eslint_d` |
| C / C++ | `cpplint` |
| Go | `golangci-lint` |
| Dockerfile | `hadolint` |
| Markdown | `markdownlint` |
| JSON | `jsonlint` |
| YAML | `yamllint` |
| Lua | `luacheck` |
| Text | `codespell` |

---

### Telescope

Defined in:

```text
lua/plugins/telescope.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<C-p>` | Normal | Find files |
| `<C-g>` | Normal | Live grep |
| `<C-b>` | Normal | List open buffers |
| `<C-h>` | Normal | Search help tags |

Useful commands:

```vim
:Telescope find_files
:Telescope live_grep
:Telescope buffers
:Telescope help_tags
```

---

### Vivify

Defined in:

```text
lua/plugins/vivify.lua
lua/vim-options.lua
```

Recommended keymaps:

| Key | Mode | Action |
|---|---:|---|
| `<leader>ms` | Normal | Start Vivify |
| `<leader>mx` | Normal | Stop Vivify |
| `<leader>mp` | Normal | Toggle Vivify |

Avoid using `<C-p>` for Vivify because Telescope uses `<C-p>`.

Commands:

```vim
:Vivify
```

---

### Neo-tree

Global keymap:

| Key | Mode | Action |
|---|---:|---|
| `<C-n>` | Normal | Reveal current file in Neo-tree |

Neo-tree internal mappings while the Neo-tree window is focused:

| Key | Action |
|---|---|
| `o` | Open file or directory |
| `<Enter>` | Open file or directory |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `t` | Open in new tab |
| `C` | Close node |
| `z` | Close all nodes |
| `R` | Refresh |
| `a` | Add file or directory |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy to clipboard |
| `x` | Cut to clipboard |
| `p` | Paste from clipboard |
| `q` | Close Neo-tree window |

---

### Debugging / DAP

Defined in:

```text
lua/plugins/debug.lua
```

| Key | Mode | Action |
|---|---:|---|
| `<F5>` | Normal | Debug start / continue |
| `<F1>` | Normal | Debug step into |
| `<F2>` | Normal | Debug step over |
| `<F3>` | Normal | Debug step out |
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dB` | Normal | Set conditional breakpoint |
| `<leader>du` | Normal | Toggle DAP UI |
| `<leader>dr` | Normal | Open DAP REPL |
| `<leader>dl` | Normal | Run last debug session |
| `<leader>dt` | Normal | Terminate debug session |

Debug adapter requirements:

```text
debugpy  -> Python debugging
delve    -> Go debugging
```

---

### Git / Gitsigns

Defined in:

```text
lua/plugins/gitsigns.lua
```

| Key | Mode | Action |
|---|---:|---|
| `]c` | Normal | Jump to next Git change |
| `[c` | Normal | Jump to previous Git change |
| `<leader>gs` | Normal | Stage current hunk |
| `<leader>gr` | Normal | Reset current hunk |
| `<leader>gs` | Visual | Stage selected hunk |
| `<leader>gr` | Visual | Reset selected hunk |
| `<leader>gS` | Normal | Stage entire buffer |
| `<leader>gR` | Normal | Reset entire buffer |
| `<leader>gu` | Normal | Undo staged hunk |
| `<leader>gp` | Normal | Preview hunk |
| `<leader>gb` | Normal | Blame current line |
| `<leader>gd` | Normal | Diff against index |
| `<leader>gD` | Normal | Diff against last commit |
| `<leader>gtb` | Normal | Toggle current-line blame |
| `<leader>gtd` | Normal | Toggle deleted lines |

---

### Treesitter Textobjects

Defined in:

```text
lua/plugins/treesitter.lua
```

Selection keymaps:

| Key | Mode | Action |
|---|---:|---|
| `af` | Visual / Operator-pending | Select outer function |
| `if` | Visual / Operator-pending | Select inner function |
| `ac` | Visual / Operator-pending | Select outer class |
| `ic` | Visual / Operator-pending | Select inner class |
| `aa` | Visual / Operator-pending | Select outer parameter |
| `ia` | Visual / Operator-pending | Select inner parameter |

Movement keymaps:

| Key | Mode | Action |
|---|---:|---|
| `]f` | Normal | Go to next function start |
| `]F` | Normal | Go to next function end |
| `[f` | Normal | Go to previous function start |
| `[F` | Normal | Go to previous function end |
| `]c` | Normal | Go to next class start |
| `]C` | Normal | Go to next class end |
| `[c` | Normal | Go to previous class start |
| `[C` | Normal | Go to previous class end |

Note: `]c` and `[c` may overlap conceptually with Gitsigns navigation. If Git hunk navigation takes precedence in Git-tracked files, use the Gitsigns mappings there.

---

### Autopairs

Defined in:

```text
lua/plugins/autopairs.lua
```

No hotkeys.

Behavior:

```text
(  ->  ()
[  ->  []
{  ->  {}
"  ->  ""
'  ->  ''
```

It also integrates with `nvim-cmp` so completion confirmation can insert paired characters for functions/methods.

---

### Indent Guides

Defined in:

```text
lua/plugins/indent_line.lua
```

No hotkeys.

Behavior:

```text
Adds indentation guides in normal code buffers.
Excludes dashboards, Neo-tree, Lazy, Mason, and similar plugin windows.
```

---

## 12. Updating and Maintaining Components

### Lazy Plugins

Open Lazy:

```vim
:Lazy
```

Common commands:

```vim
:Lazy sync
:Lazy restore
:Lazy update
:Lazy clean
:Lazy check
:Lazy log
```

Use `restore` when you want the versions pinned by `lazy-lock.json`:

```vim
:Lazy restore
```

Use `update` when you want to update plugins and refresh `lazy-lock.json`:

```vim
:Lazy update
```

Use `sync` after editing plugin specs:

```vim
:Lazy sync
```

---

### Mason Tools

Open Mason:

```vim
:Mason
```

Update registry/packages:

```vim
:MasonUpdate
```

Mason Tool Installer config lives in:

```text
lua/plugins/lsp-config.lua
```

Look for:

```lua
require('mason-tool-installer').setup {
  ensure_installed = {
    ...
  },
}
```

Add CLI tools there.

Examples:

```lua
'black',
'isort',
'ruff',
'stylua',
'shellcheck',
'shfmt',
'prettier',
'gofumpt',
'golangci-lint',
'debugpy',
'delve',
```

---

### LSP Servers

LSP server installation and setup live in:

```text
lua/plugins/lsp-config.lua
```

Mason LSP installation list:

```lua
require('mason-lspconfig').setup {
  ensure_installed = {
    ...
  },
}
```

Server-specific config lives in the `servers` table:

```lua
local servers = {
  lua_ls = {},
  pyright = {},
  bashls = {},
}
```

Verify:

```vim
:LspInfo
:checkhealth lsp
```

---

### Treesitter

Config lives in:

```text
lua/plugins/treesitter.lua
```

Update parsers:

```vim
:TSUpdate
```

Install a parser:

```vim
:TSInstall python
:TSInstall lua
:TSInstall markdown
```

View parser status:

```vim
:TSInstallInfo
```

Health check:

```vim
:checkhealth nvim-treesitter
```

Compiler dependencies:

```bash
sudo apt install -y build-essential gcc g++ make
```

---

### Formatters

Config lives in:

```text
lua/plugins/formatting.lua
```

Check health:

```vim
:checkhealth conform
```

Manual format:

```text
<leader>f
```

Verify tools:

```bash
which stylua
which black
which isort
which prettier
which shfmt
which clang-format
which gofmt
```

---

### Linters

Config lives in:

```text
lua/plugins/linting.lua
```

Manual lint:

```text
<leader>l
```

Verify tools:

```bash
which pylint
which ruff
which eslint_d
which shellcheck
which cpplint
which golangci-lint
which hadolint
which jsonlint
which yamllint
which markdownlint
which luacheck
which codespell
```

---

### Debugging / DAP

Config lives in:

```text
lua/plugins/debug.lua
```

Mason-managed adapters:

```text
debugpy
delve
```

Verify Python debug adapter:

```bash
~/.local/share/nvim/python/venv/bin/python -m debugpy --help
```

Verify Go debug adapter:

```bash
which dlv
```

Open Mason:

```vim
:Mason
```

---

### Telescope

Config lives in:

```text
lua/plugins/telescope.lua
```

Check health:

```vim
:checkhealth telescope
```

Test:

```vim
:Telescope find_files
:Telescope live_grep
:Telescope buffers
:Telescope help_tags
```

Required tools:

```bash
sudo apt install -y ripgrep fd-find
```

---

### Neo-tree

Config lives in:

```text
lua/plugins/neotree.lua
```

Commands:

```vim
:Neotree
:Neotree filesystem reveal left
```

Shortcut:

```text
<C-n>
```

If image support causes VM/terminal issues, remove this optional dependency from `neotree.lua`:

```lua
'3rd/image.nvim',
```

Then run:

```vim
:Lazy sync
```

---

### Vivify

Config lives in:

```text
lua/plugins/vivify.lua
```

Commands:

```vim
:Vivify
:Vivify
:Vivify
```

If the plugin does not work, manually install its web app dependencies:

```bash
cd ~/.local/share/nvim/lazy/vivify.vim
yarn install
```

Required packages:

```bash
sudo apt install -y nodejs npm
sudo npm install -g yarn
```

In a VM or headless environment, the browser may not open automatically. The config should echo a preview URL that can be copied into a host browser.

---

### Nightfox / Colorscheme

Config lives in:

```text
lua/plugins/nightfox.lua
```

Current colorscheme:

```lua
vim.cmd.colorscheme 'nightfox'
```

---

### Lualine

Config lives in:

```text
lua/plugins/lualine.lua
```

Recommended theme:

```lua
theme = 'auto'
```

This allows lualine to follow the active colorscheme.

---

## 13. Validation Checklist

After setup or major changes, run:

```bash
nvim --headless "+Lazy sync" +qa
```

Then open Neovim:

```bash
nvim
```

Inside Neovim:

```vim
:ConfigHealth
:checkhealth
:Lazy
:Mason
:LspInfo
:TSInstallInfo
```

Test core commands:

```vim
:Telescope find_files
:Telescope live_grep
:Neotree filesystem reveal left
:Vivify
```

Test core mappings:

```text
<C-p>       Telescope find files
<C-g>       Telescope live grep
<C-n>       Neo-tree reveal left
<leader>f   Format with conform
<leader>l   Lint current file
<leader>db  Toggle debug breakpoint
<leader>gs  Git stage hunk
```

---

## 14. Troubleshooting

### Neovim opens without this config

Check:

```bash
ls ~/.config/nvim/init.lua
```

### Plugin files exist but do not load

Confirm `init.lua` imports only:

```lua
{ import = 'plugins' },
```

### `lazy.nvim requires Neovim >= 0.8.0`

Check your active Neovim version:

```bash
which nvim
nvim --version
```

If it reports an old Debian package such as:

```text
/usr/bin/nvim
NVIM v0.7.2
```

install or activate the modern official Neovim release:

```bash
mkdir -p ~/tools/neovim
cd ~/tools/neovim

curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf nvim-linux-x86_64
tar xzf nvim-linux-x86_64.tar.gz

mkdir -p ~/.local/bin
ln -sf "$HOME/tools/neovim/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"

source ~/.bashrc
hash -r

which nvim
nvim --version
```

Expected:

```text
/home/dev1/.local/bin/nvim
```

Then rerun:

```bash
nvim --headless "+Lazy sync" +qa
```


### Lazy errors

Run:

```vim
:Lazy
:Lazy sync
:messages
```

### Python provider errors

Check:

```bash
ls ~/.local/share/nvim/python/venv/bin/python
~/.local/share/nvim/python/venv/bin/python -m pip show pynvim
```

Inside Neovim:

```vim
:checkhealth provider
```

### Telescope live grep fails

Install ripgrep:

```bash
sudo apt install -y ripgrep
```

### Telescope file search fails or is slow

Fix `fd`:

```bash
sudo apt install -y fd-find
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

### Treesitter parser build fails

Install compiler tooling:

```bash
sudo apt install -y build-essential gcc g++ make
```

Then:

```vim
:TSUpdate
```

### Icons, dashboard, or Neo-tree glyphs look broken

This usually means the terminal is not using a Nerd Font.

Verify the font is installed:

```bash
fc-list | grep -i "JetBrains.*Nerd"
```

Then set GNOME Terminal manually:

```text
GNOME Terminal → Preferences → your active profile → Text
Enable Custom font
Select JetBrainsMono Nerd Font or JetBrainsMono Nerd Font Mono
Close and reopen the terminal
```

If you are using SSH or a terminal from the host OS, install and select the Nerd Font on the host terminal application. Font rendering is controlled by the terminal client.

### Vivify does not open

Install Node/Yarn tooling:

```bash
sudo apt install -y nodejs npm
sudo npm install -g yarn
```

Then:

```bash
cd ~/.local/share/nvim/lazy/vivify.vim
yarn install
```

### Neo-tree image errors in VM

Remove optional image support:

```lua
'3rd/image.nvim',
```

Then:

```vim
:Lazy sync
```

### Gitsigns does not show signs

Confirm the file is inside a Git repository:

```bash
git status
```

Confirm Git exists:

```bash
which git
```

### DAP / Debugging does not work

Check Mason:

```vim
:Mason
```

Verify Python debugpy:

```bash
~/.local/share/nvim/python/venv/bin/python -m debugpy --help
```

Verify Go Delve:

```bash
which dlv
```

---

## 15. Quick Command Reference

```vim
:ConfigHealth       Run custom health checks
:checkhealth        Run Neovim/plugin health checks
:Lazy               Open Lazy plugin manager
:Lazy sync          Install/sync plugins
:Lazy restore       Restore locked plugin versions
:Lazy update        Update plugins
:Mason              Open Mason tool manager
:MasonUpdate        Update Mason registry/packages
:LspInfo            Show attached LSP clients
:TSUpdate           Update Treesitter parsers
:TSInstallInfo      Show Treesitter parser status
:Telescope          Open Telescope picker list
:Neotree            Open Neo-tree
:Vivify    Start Vivify
```

---

Bootstrap from repo root:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 16. Minimal Final Smoke Test

Run this after any fresh install or major refactor:

```bash
source ~/.bashrc

nvim --headless "+Lazy sync" +qa
nvim --headless "+TSUpdate" +qa
```

Then inside Neovim:

```vim
:ConfigHealth
:checkhealth
:Lazy
:Mason
:LspInfo
:TSInstallInfo
```

Open a few test files:

```bash
nvim README.md
nvim test.py
nvim test.lua
nvim test.sh
```

Confirm:

```text
Telescope opens with Ctrl+p
Neo-tree opens/reveals with Ctrl+n
Formatting works with Space f
Linting works with Space l
Git signs appear inside a Git repo
DAP breakpoint toggles with Space d b
Vivify opens with Space m p
```

If those work, the build is operational.
