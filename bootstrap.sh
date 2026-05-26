#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh
#
# Bootstrap AM-Turing/nvim-personal on a Debian/Ubuntu-based VM.
#
# Primary flow:
#   1. Check for an existing ~/.config/nvim.
#   2. If one exists, ask whether to upgrade/replace/skip.
#   3. Clone the config from GitHub using SSH or HTTPS.
#   4. Install apt dependencies.
#   5. Set up shell PATH helpers.
#   6. Set up the Debian-safe Neovim Python provider venv.
#   7. Install common npm/gem/go/rust tooling when available.
#   8. Run Lazy/Treesitter/health validation.
#
# Usage:
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
#
# Optional examples:
#   ./bootstrap.sh --yes
#   ./bootstrap.sh --repo-mode https
#   ./bootstrap.sh --repo-mode ssh
#   ./bootstrap.sh --existing-mode backup-replace
#   ./bootstrap.sh --existing-mode upgrade-in-place
#   ./bootstrap.sh --skip-apt
#   ./bootstrap.sh --skip-node-globals
#   ./bootstrap.sh --skip-rust
#   ./bootstrap.sh --skip-go
#
# Repository:
#   SSH:   git@github.com:AM-Turing/nvim-personal.git
#   HTTPS: https://github.com/AM-Turing/nvim-personal.git

readonly SSH_REPO="git@github.com:AM-Turing/nvim-personal.git"
readonly HTTPS_REPO="https://github.com/AM-Turing/nvim-personal.git"

readonly NVIM_CONFIG_DIR="$HOME/.config/nvim"
readonly NVIM_CONFIG_PARENT="$HOME/.config"
readonly NVIM_DATA_DIR="$HOME/.local/share/nvim"
readonly NVIM_PYTHON_DIR="$NVIM_DATA_DIR/python"
readonly NVIM_PYTHON_VENV="$NVIM_PYTHON_DIR/venv"
readonly LOCAL_BIN="$HOME/.local/bin"

REPO_MODE=""
EXISTING_MODE=""
ASSUME_YES="false"

SKIP_APT="false"
SKIP_NODE_GLOBALS="false"
SKIP_RUST="false"
SKIP_GO="false"
SKIP_GEM="false"
SKIP_VALIDATION="false"

timestamp() {
  date +"%Y%m%d-%H%M%S"
}

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
bootstrap.sh - bootstrap AM-Turing/nvim-personal

Usage:
  ./bootstrap.sh [options]

Options:
  --yes
      Use defaults where possible.

  --repo-mode ssh|https
      Select GitHub clone method.
      Default interactive behavior:
        - use ssh if GitHub SSH appears available
        - otherwise use https

  --existing-mode backup-replace|upgrade-in-place|skip
      Behavior when ~/.config/nvim already exists.
        backup-replace:
          Back up existing ~/.config/nvim, then clone a fresh copy.
        upgrade-in-place:
          Back up existing ~/.config/nvim, then clone to a temp dir and rsync into place.
        skip:
          Do not modify ~/.config/nvim.

  --skip-apt
      Do not install apt packages.

  --skip-node-globals
      Do not install global npm packages.

  --skip-rust
      Do not install rustup/stylua through cargo.

  --skip-go
      Do not install gopls through go.

  --skip-gem
      Do not install Ruby gems.

  --skip-validation
      Do not run Neovim validation commands.

  -h, --help
      Show this help text.

Examples:
  ./bootstrap.sh
  ./bootstrap.sh --yes --repo-mode https
  ./bootstrap.sh --existing-mode backup-replace
  ./bootstrap.sh --skip-rust --skip-go
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y)
      ASSUME_YES="true"
      shift
      ;;
    --repo-mode)
      REPO_MODE="${2:-}"
      [[ "$REPO_MODE" == "ssh" || "$REPO_MODE" == "https" ]] || die "--repo-mode must be ssh or https"
      shift 2
      ;;
    --existing-mode)
      EXISTING_MODE="${2:-}"
      [[ "$EXISTING_MODE" == "backup-replace" || "$EXISTING_MODE" == "upgrade-in-place" || "$EXISTING_MODE" == "skip" ]] || die "--existing-mode must be backup-replace, upgrade-in-place, or skip"
      shift 2
      ;;
    --skip-apt)
      SKIP_APT="true"
      shift
      ;;
    --skip-node-globals)
      SKIP_NODE_GLOBALS="true"
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

choose_existing_mode() {
  if [[ -n "$EXISTING_MODE" ]]; then
    return
  fi

  if [[ "$ASSUME_YES" == "true" ]]; then
    EXISTING_MODE="backup-replace"
    return
  fi

  cat <<EOF

Existing Neovim config detected:

  $NVIM_CONFIG_DIR

Choose how to proceed:

  1) backup-replace
     Back up existing config, then clone this repo as a fresh ~/.config/nvim.

  2) upgrade-in-place
     Back up existing config, clone this repo to a temp dir, then rsync it into ~/.config/nvim.
     This preserves extra files not overwritten by the repo, but old files may remain.

  3) skip
     Do not modify ~/.config/nvim.

EOF

  local choice
  while true; do
    read -r -p "Select [1/2/3]: " choice
    case "$choice" in
      1) EXISTING_MODE="backup-replace"; break ;;
      2) EXISTING_MODE="upgrade-in-place"; break ;;
      3) EXISTING_MODE="skip"; break ;;
      *) warn "Please choose 1, 2, or 3." ;;
    esac
  done
}

github_ssh_available() {
  command -v ssh >/dev/null 2>&1 || return 1

  # BatchMode prevents password/passphrase prompts.
  # GitHub returns exit status 1 after successful authentication because shell access is not provided,
  # so check output text instead of only exit status.
  local output
  output="$(ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 || true)"
  grep -qi "successfully authenticated" <<<"$output"
}

choose_repo_mode() {
  if [[ -n "$REPO_MODE" ]]; then
    return
  fi

  if github_ssh_available; then
    if [[ "$ASSUME_YES" == "true" ]]; then
      REPO_MODE="ssh"
    elif confirm "GitHub SSH authentication appears available. Clone with SSH?" "y"; then
      REPO_MODE="ssh"
    else
      REPO_MODE="https"
    fi
  else
    warn "GitHub SSH authentication was not detected. HTTPS will be used unless you choose SSH manually."

    if [[ "$ASSUME_YES" == "true" ]]; then
      REPO_MODE="https"
      return
    fi

    local choice
    while true; do
      read -r -p "Clone using [1] HTTPS or [2] SSH anyway? " choice
      case "$choice" in
        1) REPO_MODE="https"; break ;;
        2) REPO_MODE="ssh"; break ;;
        *) warn "Please choose 1 or 2." ;;
      esac
    done
  fi
}

repo_url() {
  if [[ "$REPO_MODE" == "ssh" ]]; then
    printf '%s\n' "$SSH_REPO"
  else
    printf '%s\n' "$HTTPS_REPO"
  fi
}

install_apt_dependencies() {
  if [[ "$SKIP_APT" == "true" ]]; then
    warn "Skipping apt dependency installation."
    return
  fi

  command -v apt-get >/dev/null 2>&1 || die "apt-get not found. This bootstrap script targets Debian/Ubuntu-based systems."

  log "Installing apt dependencies"
  sudo apt-get update

  sudo apt-get install -y \
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
    codespell \
    neovim
}

ensure_bashrc_block() {
  local bashrc="$HOME/.bashrc"
  local begin="# >>> nvim-personal bootstrap >>>"
  local end="# <<< nvim-personal bootstrap <<<"

  log "Ensuring ~/.bashrc PATH block"

  touch "$bashrc"

  if grep -Fq "$begin" "$bashrc"; then
    log "Existing nvim-personal PATH block found in ~/.bashrc. Leaving it unchanged."
    return
  fi

  cat >>"$bashrc" <<'EOF'

# >>> nvim-personal bootstrap >>>
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
# <<< nvim-personal bootstrap <<<
EOF
}

ensure_fd_symlink() {
  log "Ensuring fd command exists"

  mkdir -p "$LOCAL_BIN"

  if command -v fd >/dev/null 2>&1; then
    log "fd already available: $(command -v fd)"
    return
  fi

  if command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
    log "Created fd symlink: $LOCAL_BIN/fd -> $(command -v fdfind)"
    return
  fi

  warn "fd/fdfind not found. Telescope file finding may be degraded."
}

setup_python_provider() {
  log "Setting up Neovim Python provider venv"

  mkdir -p "$NVIM_PYTHON_DIR"

  if [[ ! -x "$NVIM_PYTHON_VENV/bin/python" ]]; then
    python3 -m venv "$NVIM_PYTHON_VENV"
  fi

  "$NVIM_PYTHON_VENV/bin/python" -m pip install --upgrade pip

  "$NVIM_PYTHON_VENV/bin/python" -m pip install --upgrade \
    pynvim \
    debugpy \
    ruff \
    black \
    isort \
    mypy
}

install_node_globals() {
  if [[ "$SKIP_NODE_GLOBALS" == "true" ]]; then
    warn "Skipping global npm tool installation."
    return
  fi

  command -v npm >/dev/null 2>&1 || {
    warn "npm not found. Skipping npm global tools."
    return
  }

  log "Installing global npm tools"

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

install_rust_and_stylua() {
  if [[ "$SKIP_RUST" == "true" ]]; then
    warn "Skipping Rust/stylua installation."
    return
  fi

  if ! command -v cargo >/dev/null 2>&1; then
    log "Installing rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  fi

  if command -v cargo >/dev/null 2>&1; then
    log "Installing/updating stylua through cargo"
    cargo install stylua || warn "cargo install stylua failed. Mason may still install stylua."
  else
    warn "cargo not found after rustup step. Skipping stylua cargo install."
  fi
}

install_go_tools() {
  if [[ "$SKIP_GO" == "true" ]]; then
    warn "Skipping Go tool installation."
    return
  fi

  if command -v go >/dev/null 2>&1; then
    log "Installing/updating gopls"
    go install golang.org/x/tools/gopls@latest || warn "go install gopls failed. Mason may still install gopls."
  else
    warn "go not found. Install Go manually if you need Go/gopls support."
  fi
}

install_ruby_tools() {
  if [[ "$SKIP_GEM" == "true" ]]; then
    warn "Skipping Ruby gem installation."
    return
  fi

  if command -v gem >/dev/null 2>&1; then
    log "Installing Ruby gems"
    sudo gem install bundler ruby-lsp || warn "Ruby gem installation failed."
  else
    warn "gem not found. Skipping Ruby tooling."
  fi
}

clone_to_temp() {
  local temp_dir
  temp_dir="$(mktemp -d)"
  local url
  url="$(repo_url)"

  log "Cloning $url to temporary directory"
  git clone "$url" "$temp_dir/nvim-personal"

  printf '%s\n' "$temp_dir/nvim-personal"
}

install_config_fresh() {
  local source_dir="$1"

  mkdir -p "$NVIM_CONFIG_PARENT"

  if [[ -e "$NVIM_CONFIG_DIR" || -L "$NVIM_CONFIG_DIR" ]]; then
    die "$NVIM_CONFIG_DIR already exists. Existing setup handling should have run first."
  fi

  log "Installing Neovim config to $NVIM_CONFIG_DIR"
  cp -a "$source_dir" "$NVIM_CONFIG_DIR"
}

backup_existing_config() {
  local backup_path="$NVIM_CONFIG_DIR.backup.$(timestamp)"
  log "Backing up existing config to $backup_path"
  mv "$NVIM_CONFIG_DIR" "$backup_path"
}

replace_existing_config() {
  local source_dir="$1"
  backup_existing_config
  install_config_fresh "$source_dir"
}

upgrade_existing_config() {
  local source_dir="$1"
  local backup_path="$NVIM_CONFIG_DIR.backup.$(timestamp)"

  log "Backing up existing config to $backup_path"
  cp -a "$NVIM_CONFIG_DIR" "$backup_path"

  log "Upgrading existing config in place with rsync"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete \
      --exclude ".git" \
      "$source_dir/" \
      "$NVIM_CONFIG_DIR/"
  else
    warn "rsync not found. Falling back to cp -a. Old files may remain."
    cp -a "$source_dir/." "$NVIM_CONFIG_DIR/"
  fi
}

install_or_upgrade_config() {
  choose_repo_mode

  if [[ -e "$NVIM_CONFIG_DIR" || -L "$NVIM_CONFIG_DIR" ]]; then
    choose_existing_mode

    case "$EXISTING_MODE" in
      skip)
        warn "Skipping Neovim config installation/update."
        return
        ;;
      backup-replace)
        local source_dir
        source_dir="$(clone_to_temp)"
        replace_existing_config "$source_dir"
        ;;
      upgrade-in-place)
        local source_dir
        source_dir="$(clone_to_temp)"
        upgrade_existing_config "$source_dir"
        ;;
      *)
        die "Invalid existing mode: $EXISTING_MODE"
        ;;
    esac
  else
    local source_dir
    source_dir="$(clone_to_temp)"
    install_config_fresh "$source_dir"
  fi
}

run_neovim_validation() {
  if [[ "$SKIP_VALIDATION" == "true" ]]; then
    warn "Skipping Neovim validation."
    return
  fi

  if ! command -v nvim >/dev/null 2>&1; then
    warn "nvim not found. Skipping Neovim validation."
    return
  fi

  log "Running Lazy sync headlessly"
  nvim --headless "+Lazy sync" +qa || warn "Lazy sync failed. Open nvim and run :Lazy sync for details."

  log "Running Treesitter update headlessly"
  nvim --headless "+TSUpdate" +qa || warn "TSUpdate failed. Open nvim and run :TSUpdate for details."

  log "Running custom ConfigHealth headlessly"
  nvim --headless "+silent! ConfigHealth" +qa || warn "ConfigHealth failed or command not found. Open nvim and run :ConfigHealth."

  log "Running checkhealth headlessly"
  nvim --headless "+checkhealth" "+qa" || warn "checkhealth returned warnings/errors. Open nvim and run :checkhealth."
}

print_summary() {
  cat <<EOF

Bootstrap complete.

Next manual checks:

  source ~/.bashrc

  nvim

Inside Neovim:

  :ConfigHealth
  :checkhealth
  :Lazy
  :Mason
  :LspInfo
  :TSInstallInfo

Core mappings to test:

  Ctrl-p      Telescope find files
  Ctrl-g      Telescope live grep
  Ctrl-n      Neo-tree reveal current file
  Space f     Format current file/range
  Space l     Lint current file
  Space d b   Toggle debug breakpoint
  Space g s   Git stage hunk

Config path:

  $NVIM_CONFIG_DIR

Python provider:

  $NVIM_PYTHON_VENV/bin/python

EOF
}

main() {
  log "Starting nvim-personal bootstrap"

  install_apt_dependencies
  ensure_bashrc_block
  ensure_fd_symlink
  setup_python_provider
  install_node_globals
  install_rust_and_stylua
  install_go_tools
  install_ruby_tools
  install_or_upgrade_config
  run_neovim_validation
  print_summary
}

main "$@"
