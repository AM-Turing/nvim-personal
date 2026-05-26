#!/usr/bin/env bash
set -euo pipefail

# update.sh
#
# Update all major components for AM-Turing/nvim-personal.
#
# Intended usage from anywhere on the VM:
#
#   chmod +x update.sh
#   ./update.sh
#
# What this updates:
#   - Git repo at ~/.config/nvim, if it is a Git checkout
#   - Official modern Neovim tarball under ~/tools/neovim
#   - Neovim Python provider venv packages
#   - Global npm tools used by LSP/formatting/linting/Markdown Preview
#   - Rust-installed stylua
#   - Go-installed gopls
#   - Ruby gems
#   - Lazy plugins
#   - Mason registry/packages
#   - Treesitter parsers
#   - Markdown Preview app dependencies
#
# Useful flags:
#   ./update.sh --yes
#   ./update.sh --skip-repo
#   ./update.sh --skip-neovim
#   ./update.sh --skip-python
#   ./update.sh --skip-node
#   ./update.sh --skip-rust
#   ./update.sh --skip-go
#   ./update.sh --skip-gem
#   ./update.sh --skip-lazy
#   ./update.sh --skip-mason
#   ./update.sh --skip-treesitter
#   ./update.sh --skip-markdown-preview
#   ./update.sh --skip-validation
#   ./update.sh --restore-lock
#
# Notes:
#   - --restore-lock uses :Lazy restore instead of :Lazy update.
#   - Default behavior updates Lazy plugins and may modify lazy-lock.json.
#   - Commit lazy-lock.json after reviewing plugin updates.

readonly NVIM_CONFIG_DIR="$HOME/.config/nvim"
readonly NVIM_DATA_DIR="$HOME/.local/share/nvim"
readonly NVIM_PYTHON_VENV="$NVIM_DATA_DIR/python/venv"
readonly LOCAL_BIN="$HOME/.local/bin"
readonly NEOVIM_TOOLS_DIR="$HOME/tools/neovim"
readonly MODERN_NVIM_BIN="$NEOVIM_TOOLS_DIR/nvim-linux-x86_64/bin/nvim"
readonly MARKDOWN_PREVIEW_DIR="$NVIM_DATA_DIR/lazy/markdown-preview.nvim"

ASSUME_YES="false"

SKIP_REPO="false"
SKIP_NEOVIM="false"
SKIP_PYTHON="false"
SKIP_NODE="false"
SKIP_RUST="false"
SKIP_GO="false"
SKIP_GEM="false"
SKIP_LAZY="false"
SKIP_MASON="false"
SKIP_TREESITTER="false"
SKIP_MARKDOWN_PREVIEW="false"
SKIP_VALIDATION="false"

RESTORE_LOCK="false"

log() {
  printf '\n[+] %s\n' "$*"
}

warn() {
  printf '\n[!] %s\n' "$*" >&2
}

die() {
  printf '\n[ERROR] %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
update.sh - update AM-Turing/nvim-personal components

Usage:
  ./update.sh [options]

Options:
  --yes
      Use defaults where possible.

  --restore-lock
      Use :Lazy restore instead of :Lazy update.
      This restores plugin versions from lazy-lock.json instead of updating them.

  --skip-repo
      Do not git pull ~/.config/nvim.

  --skip-neovim
      Do not update the official Neovim tarball.

  --skip-python
      Do not update the Neovim Python provider venv packages.

  --skip-node
      Do not update global npm packages.

  --skip-rust
      Do not update stylua through cargo.

  --skip-go
      Do not update gopls through go.

  --skip-gem
      Do not update Ruby gems.

  --skip-lazy
      Do not update Lazy plugins.

  --skip-mason
      Do not update Mason registry/packages.

  --skip-treesitter
      Do not update Treesitter parsers.

  --skip-markdown-preview
      Do not update markdown-preview.nvim app dependencies.

  --skip-validation
      Do not run health/validation commands.

  -h, --help
      Show this help text.

Examples:
  ./update.sh
  ./update.sh --restore-lock
  ./update.sh --skip-node --skip-gem
  ./update.sh --yes
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y)
      ASSUME_YES="true"
      shift
      ;;
    --restore-lock)
      RESTORE_LOCK="true"
      shift
      ;;
    --skip-repo)
      SKIP_REPO="true"
      shift
      ;;
    --skip-neovim)
      SKIP_NEOVIM="true"
      shift
      ;;
    --skip-python)
      SKIP_PYTHON="true"
      shift
      ;;
    --skip-node)
      SKIP_NODE="true"
      shift
      ;;
    --skip-rust)
      SKIP_RUST="true"
      shift
      ;;
    --skip-go)
      SKIP_GO="true"
      shift
      ;;
    --skip-gem)
      SKIP_GEM="true"
      shift
      ;;
    --skip-lazy)
      SKIP_LAZY="true"
      shift
      ;;
    --skip-mason)
      SKIP_MASON="true"
      shift
      ;;
    --skip-treesitter)
      SKIP_TREESITTER="true"
      shift
      ;;
    --skip-markdown-preview)
      SKIP_MARKDOWN_PREVIEW="true"
      shift
      ;;
    --skip-validation)
      SKIP_VALIDATION="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

confirm() {
  local prompt="$1"
  local default="${2:-n}"

  if [[ "$ASSUME_YES" == "true" ]]; then
    [[ "$default" =~ ^[Yy]$ ]]
    return $?
  fi

  local suffix="[y/N]"
  [[ "$default" =~ ^[Yy]$ ]] && suffix="[Y/n]"

  local answer
  read -r -p "$prompt $suffix " answer
  answer="${answer:-$default}"

  [[ "$answer" =~ ^[Yy]$ ]]
}

ensure_nvim_exists() {
  command -v nvim >/dev/null 2>&1 || die "nvim was not found in PATH. Run bootstrap.sh first."
}

update_repo() {
  if [[ "$SKIP_REPO" == "true" ]]; then
    warn "Skipping repo update."
    return
  fi

  if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    warn "$NVIM_CONFIG_DIR does not exist. Skipping repo update."
    return
  fi

  if [[ ! -d "$NVIM_CONFIG_DIR/.git" ]]; then
    warn "$NVIM_CONFIG_DIR is not a Git checkout. Skipping git pull."
    return
  fi

  log "Updating Neovim config Git repo"
  git -C "$NVIM_CONFIG_DIR" status --short || true

  if [[ "$ASSUME_YES" != "true" ]]; then
    if ! confirm "Run git pull in $NVIM_CONFIG_DIR?" "y"; then
      warn "Skipping git pull."
      return
    fi
  fi

  git -C "$NVIM_CONFIG_DIR" pull --ff-only || {
    warn "git pull --ff-only failed. Resolve local changes or merge conflicts manually."
    return
  }
}

update_modern_neovim() {
  if [[ "$SKIP_NEOVIM" == "true" ]]; then
    warn "Skipping Neovim binary update."
    return
  fi

  log "Updating official modern Neovim release tarball"

  mkdir -p "$NEOVIM_TOOLS_DIR"
  cd "$NEOVIM_TOOLS_DIR"

  local tarball="nvim-linux-x86_64.tar.gz"
  local url="https://github.com/neovim/neovim/releases/latest/download/$tarball"

  curl -fL -o "$tarball" "$url"

  rm -rf nvim-linux-x86_64
  tar xzf "$tarball"

  mkdir -p "$LOCAL_BIN"
  ln -sf "$MODERN_NVIM_BIN" "$LOCAL_BIN/nvim"

  hash -r || true

  "$LOCAL_BIN/nvim" --version | head -n 1
}

update_python_provider() {
  if [[ "$SKIP_PYTHON" == "true" ]]; then
    warn "Skipping Python provider update."
    return
  fi

  if [[ ! -x "$NVIM_PYTHON_VENV/bin/python" ]]; then
    warn "Neovim Python provider venv not found. Creating it."
    mkdir -p "$(dirname "$NVIM_PYTHON_VENV")"
    python3 -m venv "$NVIM_PYTHON_VENV"
  fi

  log "Updating Neovim Python provider packages"

  "$NVIM_PYTHON_VENV/bin/python" -m pip install --upgrade pip

  "$NVIM_PYTHON_VENV/bin/python" -m pip install --upgrade \
    pynvim \
    debugpy \
    ruff \
    black \
    isort \
    mypy
}

update_node_globals() {
  if [[ "$SKIP_NODE" == "true" ]]; then
    warn "Skipping global npm updates."
    return
  fi

  command -v npm >/dev/null 2>&1 || {
    warn "npm not found. Skipping global npm updates."
    return
  }

  log "Updating global npm tools"

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
}

update_rust_tools() {
  if [[ "$SKIP_RUST" == "true" ]]; then
    warn "Skipping Rust tool updates."
    return
  fi

  if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  fi

  command -v rustup >/dev/null 2>&1 && {
    log "Updating Rust toolchain"
    rustup update || warn "rustup update failed."
  }

  if command -v cargo >/dev/null 2>&1; then
    log "Updating stylua through cargo"
    cargo install stylua || warn "cargo install stylua failed."
  else
    warn "cargo not found. Skipping stylua update."
  fi
}

update_go_tools() {
  if [[ "$SKIP_GO" == "true" ]]; then
    warn "Skipping Go tool updates."
    return
  fi

  if command -v go >/dev/null 2>&1; then
    log "Updating gopls"
    go install golang.org/x/tools/gopls@latest || warn "go install gopls failed."
  else
    warn "go not found. Skipping Go tool update."
  fi
}

update_ruby_tools() {
  if [[ "$SKIP_GEM" == "true" ]]; then
    warn "Skipping Ruby gem updates."
    return
  fi

  if command -v gem >/dev/null 2>&1; then
    log "Updating Ruby gems"
    sudo gem update bundler ruby-lsp || sudo gem install bundler ruby-lsp || warn "Ruby gem update/install failed."
  else
    warn "gem not found. Skipping Ruby tool update."
  fi
}

run_nvim_headless() {
  local description="$1"
  shift

  log "$description"
  nvim --headless "$@" +qa || warn "$description failed. Open nvim and inspect :messages."
}

update_lazy_plugins() {
  if [[ "$SKIP_LAZY" == "true" ]]; then
    warn "Skipping Lazy plugin update."
    return
  fi

  ensure_nvim_exists

  if [[ "$RESTORE_LOCK" == "true" ]]; then
    run_nvim_headless "Restoring Lazy plugins from lazy-lock.json" "+Lazy restore"
  else
    run_nvim_headless "Updating Lazy plugins" "+Lazy update"
  fi

  run_nvim_headless "Syncing Lazy plugins" "+Lazy sync"
}

update_mason() {
  if [[ "$SKIP_MASON" == "true" ]]; then
    warn "Skipping Mason update."
    return
  fi

  ensure_nvim_exists

  # Mason commands are user commands. silent! keeps this safe if Mason has not loaded yet.
  run_nvim_headless "Updating Mason registry/packages" "+silent! MasonUpdate"
}

update_treesitter() {
  if [[ "$SKIP_TREESITTER" == "true" ]]; then
    warn "Skipping Treesitter update."
    return
  fi

  ensure_nvim_exists
  run_nvim_headless "Updating Treesitter parsers" "+TSUpdate"
}

update_markdown_preview() {
  if [[ "$SKIP_MARKDOWN_PREVIEW" == "true" ]]; then
    warn "Skipping Markdown Preview app update."
    return
  fi

  if [[ ! -d "$MARKDOWN_PREVIEW_DIR" ]]; then
    warn "markdown-preview.nvim directory not found. It may install during :Lazy sync."
    return
  fi

  if ! command -v yarn >/dev/null 2>&1; then
    warn "yarn not found. Skipping Markdown Preview app dependency update."
    return
  fi

  log "Updating Markdown Preview app dependencies"
  cd "$MARKDOWN_PREVIEW_DIR"
  yarn install || warn "yarn install failed in markdown-preview.nvim."
}

run_validation() {
  if [[ "$SKIP_VALIDATION" == "true" ]]; then
    warn "Skipping validation."
    return
  fi

  ensure_nvim_exists

  log "Active Neovim binary: $(command -v nvim)"
  nvim --version | head -n 1 || true

  run_nvim_headless "Running ConfigHealth" "+silent! ConfigHealth"
  run_nvim_headless "Running checkhealth" "+checkhealth"
}

print_summary() {
  cat <<EOF

Update complete.

Recommended manual checks:

  source ~/.bashrc
  hash -r

  which nvim
  nvim --version

Open Neovim:

  nvim

Then run:

  :ConfigHealth
  :checkhealth
  :Lazy
  :Mason
  :LspInfo
  :TSInstallInfo

If plugins were updated, review and commit:

  cd $NVIM_CONFIG_DIR
  git status
  git diff lazy-lock.json

If lazy-lock.json changed and everything works:

  git add lazy-lock.json
  git commit -m "Update Neovim plugin lockfile"

EOF
}

main() {
  log "Starting nvim-personal update"

  update_repo
  update_modern_neovim
  update_python_provider
  update_node_globals
  update_rust_tools
  update_go_tools
  update_ruby_tools
  update_lazy_plugins
  update_mason
  update_treesitter
  update_markdown_preview
  run_validation
  print_summary
}

main "$@"
