#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh
#
# Bootstrap AM-Turing/nvim-personal on a Debian/Ubuntu-based VM.
#
# This version installs:
#   - apt dependencies
#   - modern official Neovim
#   - Vivify Markdown preview binaries: viv and vivify-server
#   - JetBrainsMono Nerd Font
#   - Neovim Python provider venv
#   - common npm/rust/go/ruby tools
  - Go toolchain from apt for Mason Go packages: gopls/gofumpt
#   - this Neovim config from the current local repo when possible, otherwise GitHub
#
# Vivify source:
#   https://github.com/jannis-baum/Vivify/releases/download/v0.14.0/vivify-linux.tar.gz

readonly SSH_REPO="git@github.com:AM-Turing/nvim-personal.git"
readonly HTTPS_REPO="https://github.com/AM-Turing/nvim-personal.git"

readonly NVIM_CONFIG_DIR="$HOME/.config/nvim"
readonly NVIM_CONFIG_PARENT="$HOME/.config"
readonly NVIM_DATA_DIR="$HOME/.local/share/nvim"
readonly NVIM_PYTHON_DIR="$NVIM_DATA_DIR/python"
readonly NVIM_PYTHON_VENV="$NVIM_PYTHON_DIR/venv"
readonly LOCAL_BIN="$HOME/.local/bin"
readonly TOOLS_DIR="$HOME/tools"

readonly NEOVIM_TOOLS_DIR="$TOOLS_DIR/neovim"
readonly MODERN_NVIM_BIN="$NEOVIM_TOOLS_DIR/nvim-linux-x86_64/bin/nvim"

readonly VIVIFY_VERSION="v0.14.0"
readonly VIVIFY_URL="https://github.com/jannis-baum/Vivify/releases/download/${VIVIFY_VERSION}/vivify-linux.tar.gz"
readonly VIVIFY_TOOLS_DIR="$TOOLS_DIR/vivify"

readonly JETBRAINS_NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
readonly JETBRAINS_NERD_FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"

REPO_MODE=""
EXISTING_MODE=""
ASSUME_YES="false"

SKIP_APT="false"
SKIP_NEOVIM_INSTALL="false"
SKIP_VIVIFY_INSTALL="false"
SKIP_NERD_FONT_INSTALL="false"
SKIP_NODE_GLOBALS="false"
SKIP_RUST="false"
SKIP_GO="false"
SKIP_GEM="false"
SKIP_VALIDATION="false"

timestamp() { date +"%Y%m%d-%H%M%S"; }
log() { printf '\n[+] %s\n' "$*" >&2; }
warn() { printf '\n[!] %s\n' "$*" >&2; }
die() { printf '\n[ERROR] %s\n' "$*" >&2; exit 1; }

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

  --existing-mode backup-replace|upgrade-in-place|skip
      Behavior when ~/.config/nvim already exists.

  --skip-apt
      Do not install apt packages.

  --skip-neovim-install
      Do not install the official modern Neovim release tarball.

  --skip-vivify-install
      Do not install Vivify binaries.

  --skip-nerd-font-install
      Do not install JetBrainsMono Nerd Font.

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
    --yes|-y) ASSUME_YES="true"; shift ;;
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
    --skip-apt) SKIP_APT="true"; shift ;;
    --skip-neovim-install) SKIP_NEOVIM_INSTALL="true"; shift ;;
    --skip-vivify-install) SKIP_VIVIFY_INSTALL="true"; shift ;;
    --skip-nerd-font-install) SKIP_NERD_FONT_INSTALL="true"; shift ;;
    --skip-node-globals) SKIP_NODE_GLOBALS="true"; shift ;;
    --skip-rust) SKIP_RUST="true"; shift ;;
    --skip-go) SKIP_GO="true"; shift ;;
    --skip-gem) SKIP_GEM="true"; shift ;;
    --skip-validation) SKIP_VALIDATION="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
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

github_ssh_available() {
  command -v ssh >/dev/null 2>&1 || return 1
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
    warn "GitHub SSH authentication was not detected."
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
     Back up existing config, then clone a fresh copy.

  2) upgrade-in-place
     Back up existing config, then rsync the new repo over the existing config.

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

install_apt_dependencies() {
  if [[ "$SKIP_APT" == "true" ]]; then
    warn "Skipping apt dependency installation."
    return
  fi

  command -v apt-get >/dev/null 2>&1 || die "apt-get not found. This script targets Debian/Ubuntu."

  log "Installing apt dependencies"
  sudo apt-get update

  sudo apt-get install -y \
    git curl wget unzip tar gzip xz-utils ca-certificates gnupg \
    software-properties-common build-essential gcc g++ make cmake pkg-config \
    ripgrep fd-find jq tree xclip wl-clipboard rsync \
    python3 python3-pip python3-venv python3-dev \
    nodejs npm lua5.1 liblua5.1-0-dev libreadline-dev luarocks \
    golang-go \
    ruby-full openjdk-17-jdk clangd shellcheck codespell
}

install_modern_neovim() {
  if [[ "$SKIP_NEOVIM_INSTALL" == "true" ]]; then
    warn "Skipping official Neovim install."
    return
  fi

  log "Installing modern Neovim from official release tarball"

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

  [[ -x "$LOCAL_BIN/nvim" ]] || die "Modern Neovim install failed"
  "$LOCAL_BIN/nvim" --version | head -n 1
}

install_vivify() {
  if [[ "$SKIP_VIVIFY_INSTALL" == "true" ]]; then
    warn "Skipping Vivify install."
    return
  fi

  log "Installing Vivify ${VIVIFY_VERSION}"

  mkdir -p "$VIVIFY_TOOLS_DIR" "$LOCAL_BIN"
  cd "$VIVIFY_TOOLS_DIR"

  local archive="vivify-linux.tar.gz"

  curl -fL -o "$archive" "$VIVIFY_URL"

  rm -rf extracted
  mkdir -p extracted
  tar xzf "$archive" -C extracted

  local viv_bin
  local server_bin

  viv_bin="$(find extracted -type f -name 'viv' | head -n 1 || true)"
  server_bin="$(find extracted -type f -name 'vivify-server' | head -n 1 || true)"

  [[ -n "$viv_bin" ]] || die "Could not find viv binary in $archive"
  [[ -n "$server_bin" ]] || die "Could not find vivify-server binary in $archive"

  install -m 0755 "$viv_bin" "$LOCAL_BIN/viv"
  install -m 0755 "$server_bin" "$LOCAL_BIN/vivify-server"

  log "Vivify binaries installed:"
  printf '  %s\n' "$LOCAL_BIN/viv"
  printf '  %s\n' "$LOCAL_BIN/vivify-server"
}

install_jetbrains_nerd_font() {
  if [[ "$SKIP_NERD_FONT_INSTALL" == "true" ]]; then
    warn "Skipping JetBrainsMono Nerd Font install."
    return
  fi

  log "Installing JetBrainsMono Nerd Font"

  mkdir -p "$JETBRAINS_NERD_FONT_DIR"
  cd "$JETBRAINS_NERD_FONT_DIR"

  local archive="JetBrainsMono.zip"

  curl -fL -o "$archive" "$JETBRAINS_NERD_FONT_URL"

  # Remove old font files from this managed directory before extracting.
  find "$JETBRAINS_NERD_FONT_DIR" -type f \( -name '*.ttf' -o -name '*.otf' \) -delete

  unzip -o "$archive" -d "$JETBRAINS_NERD_FONT_DIR" >/dev/null

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -fv "$HOME/.local/share/fonts" >/dev/null || warn "fc-cache failed. You may need to refresh fonts manually."
  else
    warn "fc-cache not found. Install fontconfig or refresh fonts manually."
  fi

  log "JetBrainsMono Nerd Font installed under $JETBRAINS_NERD_FONT_DIR"
}

ensure_bashrc_block() {
  local bashrc="$HOME/.bashrc"
  local begin="# >>> nvim-personal bootstrap >>>"

  log "Ensuring ~/.bashrc PATH block"

  touch "$bashrc"

  if grep -Fq "$begin" "$bashrc"; then
    log "Existing nvim-personal PATH block found in ~/.bashrc."
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

ensure_current_shell_path() {
  # Make freshly installed user-local tools and Go tools visible during this same script run.
  # ~/.bashrc handles future shells, but Mason validation runs before the user reloads a shell.
  log "Ensuring current shell PATH includes local and Go tool directories"

  export PATH="$LOCAL_BIN:/usr/local/go/bin:$HOME/go/bin:$PATH"
  hash -r || true

  if command -v go >/dev/null 2>&1; then
    log "Go available: $(command -v go)"
    go version || true
  else
    warn "go is still not available in PATH after apt setup. Mason Go packages may fail."
  fi
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
    pynvim debugpy ruff black isort mypy
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
    dockerfile-language-server-nodejs pyright typescript typescript-language-server \
    bash-language-server vscode-langservers-extracted yaml-language-server \
    markdownlint-cli prettier yarn
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
  fi
}

install_go_tools() {
  if [[ "$SKIP_GO" == "true" ]]; then
    warn "Skipping Go tool installation."
    return
  fi

  # Ensure Go tools installed with `go install` are visible to this script and future shells.
  export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
  hash -r || true

  if command -v go >/dev/null 2>&1; then
    log "Installing/updating gopls and gofumpt through Go"
    mkdir -p "$HOME/go/bin"
    go install golang.org/x/tools/gopls@latest || warn "go install gopls failed. Mason may still install gopls."
    go install mvdan.cc/gofumpt@latest || warn "go install gofumpt failed. Mason may still install gofumpt."
  else
    warn "go not found. Install Go manually if you need Go/gopls/gofumpt support."
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

detect_local_repo_root() {
  # Prefer the already-cloned repository that contains this bootstrap script.
  # This avoids needlessly cloning the same repo again and makes fresh VM setup smoother.
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

  # If the script is run from inside the checked-out nvim-personal repository,
  # install from that local working tree.
  if [[ -d "$script_dir/.git" && -f "$script_dir/init.lua" ]]; then
    printf '%s\n' "$script_dir"
    return 0
  fi

  # If the script lives in a helper/scripts directory inside the repo, try the parent.
  local parent_dir
  parent_dir="$(cd -- "$script_dir/.." && pwd)"
  if [[ -d "$parent_dir/.git" && -f "$parent_dir/init.lua" ]]; then
    printf '%s\n' "$parent_dir"
    return 0
  fi

  return 1
}

get_config_source() {
  local local_repo

  if local_repo="$(detect_local_repo_root)"; then
    log "Using existing local repo at $local_repo"
    printf '%s\n' "$local_repo"
    return 0
  fi

  choose_repo_mode

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

  [[ ! -e "$NVIM_CONFIG_DIR" && ! -L "$NVIM_CONFIG_DIR" ]] || die "$NVIM_CONFIG_DIR already exists."

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
  rsync -a --delete --exclude ".git" "$source_dir/" "$NVIM_CONFIG_DIR/"
}

install_or_upgrade_config() {
  if [[ -e "$NVIM_CONFIG_DIR" || -L "$NVIM_CONFIG_DIR" ]]; then
    choose_existing_mode

    case "$EXISTING_MODE" in
      skip) warn "Skipping Neovim config installation/update."; return ;;
      backup-replace)
        local source_dir
        source_dir="$(get_config_source)"
        replace_existing_config "$source_dir"
        ;;
      upgrade-in-place)
        local source_dir
        source_dir="$(get_config_source)"
        upgrade_existing_config "$source_dir"
        ;;
      *) die "Invalid existing mode: $EXISTING_MODE" ;;
    esac
  else
    local source_dir
    source_dir="$(get_config_source)"
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

  log "Using Neovim: $(command -v nvim)"
  nvim --version | head -n 1 || true

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

Reload shell environment:

  source ~/.bashrc
  hash -r

Confirm binaries:

  which nvim
  nvim --version

  which viv
  which vivify-server

Expected locations:

  $LOCAL_BIN/nvim
  $LOCAL_BIN/viv
  $LOCAL_BIN/vivify-server

Test:

  nvim README.md

Inside Neovim:

  :Vivify
  :ConfigHealth
  :checkhealth
  :Lazy
  :Mason
  :LspInfo
  :TSInstallInfo


GNOME Terminal font setup is manual:

  1. Open GNOME Terminal preferences.
  2. Select your active profile.
  3. Go to Text.
  4. Enable Custom font.
  5. Select one of:
       JetBrainsMono Nerd Font
       JetBrainsMono Nerd Font Mono
  6. Close and reopen the terminal.

This is required for Neo-tree icons, dashboard glyphs, lualine icons,
and Nerd Font/Powerline symbols to render correctly.

Core mappings:

  Ctrl-p      Telescope find files
  Ctrl-g      Telescope live grep
  Ctrl-n      Neo-tree reveal current file
  Space f     Format current file/range
  Space l     Lint current file
  Space d b   Toggle debug breakpoint
  Space g s   Git stage hunk
  Space m p   Open Vivify Markdown preview

EOF
}

main() {
  log "Starting nvim-personal bootstrap"

  install_apt_dependencies
  install_modern_neovim
  install_vivify
  install_jetbrains_nerd_font
  ensure_bashrc_block
  ensure_current_shell_path
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
