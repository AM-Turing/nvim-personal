# Neovim Environment Setup

This document bootstraps this Neovim configuration on a fresh Debian/Ubuntu-based VM.

The config is based on a fork of `kickstart.nvim` and expects this repository to live at:

```bash
~/.config/nvim
```

Neovim will load:

```bash
~/.config/nvim/init.lua
```

The rest of the configuration is loaded from the `lua/` directory.

---

## 1. Expected Repository Layout

After installation, the config should look similar to this:

```text
~/.config/nvim/
├── doc/
├── init.lua
├── lazy-lock.json
├── lua/
│   ├── custom/
│   │   └── plugins/
│   ├── kickstart/
│   │   └── plugins/
│   ├── plugins/
│   └── vim-options.lua
├── NOTES.md
└── README.md
```

The key file is:

```text
init.lua
```

That file bootstraps `lazy.nvim`, loads editor options, and imports plugin specs from the `lua/` tree.

---

## 2. Install System Dependencies

Run this first on a fresh Debian/Ubuntu VM:

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

### Why these packages matter

| Package | Purpose |
|---|---|
| `git` | Required for cloning plugin repositories |
| `curl`, `wget` | Required by installers and plugin tooling |
| `unzip`, `tar`, `gzip`, `xz-utils` | Required for extracting tools, language servers, and Neovim releases |
| `build-essential`, `gcc`, `g++`, `make`, `cmake` | Required for compiling Treesitter parsers and some native plugin components |
| `ripgrep` | Required/recommended for Telescope live grep |
| `fd-find` | Required/recommended for fast file searching |
| `xclip`, `wl-clipboard` | Clipboard support for X11 and Wayland sessions |
| `python3`, `python3-pip`, `python3-venv`, `python3-dev` | Python provider support, virtual environments, and Python tooling |
| `nodejs`, `npm` | Required by many LSP servers and Markdown Preview |
| `lua5.1`, `liblua5.1-0-dev`, `libreadline-dev`, `luarocks` | Helps resolve Lua/hererocks-related plugin installation failures |
| `ruby-full` | Ruby language tooling support |
| `openjdk-17-jdk` | Java language tooling support |
| `clangd` | C/C++ language server |
| `shellcheck` | Shell script diagnostics |
| `codespell` | Spelling lint support |

---

## 3. Fix `fd` on Debian/Ubuntu

On Debian/Ubuntu, the `fd` binary is often installed as `fdfind`.

Check it:

```bash
which fdfind
```

Create a user-local symlink named `fd`:

```bash
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

Make sure `~/.local/bin` is in your shell path:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
which fd
fd --version
```

---

## 4. Install or Update Neovim

Check the version currently installed:

```bash
nvim --version
```

This configuration should be run on a current stable Neovim release. If the distro package is outdated, install Neovim manually from the official release artifact.

### Option A: Install from apt

```bash
sudo apt install -y neovim
nvim --version
```

### Option B: Install Neovim AppImage

```bash
mkdir -p ~/tools/neovim
cd ~/tools/neovim

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage

sudo ln -sf "$HOME/tools/neovim/nvim-linux-x86_64.appimage" /usr/local/bin/nvim

nvim --version
```

If the AppImage complains about FUSE, install FUSE support:

```bash
sudo apt install -y libfuse2
```

Then retry:

```bash
nvim --version
```

---

## 5. Install Python Provider Support

Neovim can use Python support for plugins and tooling. Install `pynvim` in the user environment:

```bash
python3 -m pip install --user --upgrade pynvim
```

Optional Python development tools:

```bash
python3 -m pip install --user --upgrade \
  debugpy \
  ruff \
  black \
  isort \
  mypy
```

Make sure user-level Python scripts are on your path:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
python3 -m pip show pynvim
```

Inside Neovim, later run:

```vim
:checkhealth provider
```

---

## 6. Install Node/NPM Language Tooling

Install globally useful language servers and supporting tools:

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

Optional Vue tooling:

```bash
sudo npm install -g \
  @vue/language-server \
  typescript
```

Older setups may refer to `vls`. Newer Vue projects generally use `@vue/language-server`.

### Important PATH note

Do **not** add this to your shell config:

```bash
export PATH=$PATH:/usr/bin/npm
```

`/usr/bin/npm` is the npm executable, not a directory.

If `npm` is installed through apt, this should already work:

```bash
which npm
npm --version
```

If globally installed npm binaries are not found, check:

```bash
npm config get prefix
```

Common global binary locations include:

```text
/usr/local/bin
/usr/bin
~/.npm-global/bin
```

Only directories should be added to `PATH`.

---

## 7. Install Ruby Tooling

For Ruby support:

```bash
sudo gem install bundler
```

Optional Ruby language server:

```bash
sudo gem install ruby-lsp
```

Verify:

```bash
ruby --version
gem --version
bundle --version
```

---

## 8. Install Rust and Stylua

Install Rust with `rustup`:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Load the Rust environment:

```bash
source "$HOME/.cargo/env"
```

Persist Rust in your shell:

```bash
echo 'source "$HOME/.cargo/env"' >> ~/.bashrc
```

Install `stylua`:

```bash
cargo install stylua
```

Verify:

```bash
rustc --version
cargo --version
stylua --version
```

---

## 9. Install Go

Download the current Linux AMD64 Go tarball from:

```text
https://go.dev/dl/
```

Example flow after downloading the tarball:

```bash
cd ~/Downloads

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go*.linux-amd64.tar.gz
```

Add Go to your shell path:

```bash
echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
go version
```

Install Go language tooling:

```bash
go install golang.org/x/tools/gopls@latest
```

Add the Go user binary path:

```bash
echo 'export PATH="$HOME/go/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
which gopls
gopls version
```

---

## 10. Clone This Neovim Config

Back up any existing config first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
```

Clone your fork:

```bash
git clone <YOUR_FORK_URL> ~/.config/nvim
```

Or, if copying from a local folder:

```bash
mkdir -p ~/.config
cp -a /path/to/this/config ~/.config/nvim
```

Confirm:

```bash
ls ~/.config/nvim/init.lua
ls ~/.config/nvim/lua
```

---

## 11. First Neovim Launch

Start Neovim:

```bash
nvim
```

On first launch, `lazy.nvim` should bootstrap itself and begin installing plugins.

Inside Neovim, run:

```vim
:Lazy
```

Because this repo includes `lazy-lock.json`, prefer this first for reproducible setup:

```vim
:Lazy restore
```

Then run:

```vim
:Lazy sync
```

Quit and reopen:

```vim
:qa
```

```bash
nvim
```

---

## 12. Install Mason Tools

Inside Neovim, open Mason:

```vim
:Mason
```

Recommended tools for this setup:

```text
lua-language-server
stylua
pyright
ruff
black
debugpy
bash-language-server
shellcheck
shfmt
json-lsp
yaml-language-server
marksman
dockerfile-language-server
typescript-language-server
eslint-lsp
html-lsp
css-lsp
clangd
jdtls
gopls
ruby-lsp
```

Some tools may already be installed through `apt`, `npm`, `pip`, `cargo`, `gem`, or `go install`.

Use Mason for convenience, but avoid fighting with it if a tool is already working from the system path.

---

## 13. Markdown Preview Setup

If `markdown-preview.nvim` installs but `:MarkdownPreview` does nothing, manually install its web app dependencies.

After the plugin exists:

```bash
cd ~/.local/share/nvim/lazy/markdown-preview.nvim
yarn install
```

Then restart Neovim and test:

```vim
:MarkdownPreview
```

If `yarn` is missing:

```bash
sudo npm install -g yarn
```

---

## 14. Verify Health

Run Neovim health checks:

```vim
:checkhealth
```

Targeted checks:

```vim
:checkhealth lazy
:checkhealth mason
:checkhealth provider
:checkhealth telescope
:checkhealth nvim-treesitter
```

Common success indicators:

```text
git found
curl found
rg found
fd found
node found
npm found
python provider OK
clipboard provider OK
C compiler found
```

---

## 15. Troubleshooting

### Neo-tree or Lua/hererocks install failures

If a plugin fails while installing `hererocks`, install Lua/readline dependencies:

```bash
sudo apt install -y lua5.1 liblua5.1-0-dev libreadline-dev luarocks
```

Then reopen Neovim and run:

```vim
:Lazy sync
```

### LSP servers fail to install

Make sure Node and npm exist:

```bash
which node
node --version
which npm
npm --version
```

Then install the common npm language servers:

```bash
sudo npm install -g \
  pyright \
  typescript \
  typescript-language-server \
  dockerfile-language-server-nodejs \
  bash-language-server \
  vscode-langservers-extracted \
  yaml-language-server
```

Restart Neovim and run:

```vim
:LspInfo
:Mason
:checkhealth mason
```

### Treesitter parser compilation fails

Install compiler tooling:

```bash
sudo apt install -y build-essential gcc g++ make cmake
```

Then inside Neovim:

```vim
:TSUpdate
```

### Telescope live grep does not work

Install `ripgrep`:

```bash
sudo apt install -y ripgrep
```

Verify:

```bash
rg --version
```

### Telescope file finder does not find files

Install and fix `fd`:

```bash
sudo apt install -y fd-find
mkdir -p ~/.local/bin
ln -sf "$(which fdfind)" ~/.local/bin/fd
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
fd --version
```

### Clipboard does not work

For X11:

```bash
sudo apt install -y xclip
```

For Wayland:

```bash
sudo apt install -y wl-clipboard
```

Then check:

```vim
:checkhealth provider
```

### Neovim opens without this config

Check that the config is in the correct location:

```bash
ls ~/.config/nvim/init.lua
```

If that file does not exist, Neovim is not loading this config.

### Plugin files exist but do not load

Check that `init.lua` imports the right plugin directories.

For this structure, the lazy setup should import some combination of:

```lua
{ import = 'plugins' },
{ import = 'kickstart.plugins' },
{ import = 'custom.plugins' },
```

Remember the mapping:

```text
lua/plugins/telescope.lua          -> import 'plugins'
lua/kickstart/plugins/gitsigns.lua -> import 'kickstart.plugins'
lua/custom/plugins/init.lua        -> import 'custom.plugins'
```

---

## 16. Full Bootstrap Script

This is the quick version for a new VM.

Review before running.

```bash
#!/usr/bin/env bash
set -euo pipefail

sudo apt update

sudo apt install -y \
  git curl wget unzip tar gzip xz-utils ca-certificates gnupg \
  software-properties-common \
  build-essential gcc g++ make cmake pkg-config \
  ripgrep fd-find jq tree \
  xclip wl-clipboard \
  python3 python3-pip python3-venv python3-dev \
  nodejs npm \
  lua5.1 liblua5.1-0-dev libreadline-dev luarocks \
  ruby-full openjdk-17-jdk clangd shellcheck codespell

mkdir -p "$HOME/.local/bin"

if command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

python3 -m pip install --user --upgrade pynvim debugpy ruff black isort mypy

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

sudo gem install bundler ruby-lsp

echo
echo "Base dependencies installed."
echo "Next steps:"
echo "1. Install/update Neovim if needed."
echo "2. Clone this repo to ~/.config/nvim."
echo "3. Start nvim."
echo "4. Run :Lazy restore, then :Lazy sync."
echo "5. Run :checkhealth."
```

---

## 17. Post-Install Checklist

After setup:

```vim
:Lazy restore
:Lazy sync
:Mason
:checkhealth
```

Then verify from the shell:

```bash
nvim --version
git --version
rg --version
fd --version
node --version
npm --version
python3 --version
go version
rustc --version
stylua --version
ruby --version
java --version
clangd --version
```

Not every language runtime is mandatory. Install the ones you actually use.

For a minimal Python/Lua/Markdown-focused VM, the most important pieces are:

```text
Neovim
git
curl
unzip
ripgrep
fd
gcc/build-essential
python3
pynvim
nodejs/npm
lua-language-server
stylua
pyright
ruff
black
marksman
```
