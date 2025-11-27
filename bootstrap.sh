#!/usr/bin/env bash
set -euo pipefail

if [[ "${TRACE-}" == "1" ]]; then
  set -x
fi

info() {
  printf "\033[1;34m==> %s\033[0m\n" "$*"
}

die() {
  printf "\033[1;31mError:\033[0m %s\n" "$*" >&2
  exit 1
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BREW_PREFIX=""

ensure_xcode_clt() {
  if /usr/bin/xcode-select -p >/dev/null 2>&1; then
    return
  fi
  info "Installing Xcode Command Line Tools (required for compilers/make)"
  /usr/bin/xcode-select --install || {
    cat <<'EOF'
The Xcode Command Line Tools installer was triggered. Please complete it manually,
then re-run this script.
EOF
    exit 1
  }
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX="$(brew --prefix)"
    return
  fi

  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ $(uname -m) == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
  else
    BREW_PREFIX="/usr/local"
  fi
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
}

brew_install_formulae() {
  local formulae=(
    git
    curl
    neovim
    ripgrep
    fd
    lazygit
    node
    python@3.12
    pipx
    stylua
    isort
    black
  )

  info "Installing Homebrew formulae"
  brew update >/dev/null
  for formula in "${formulae[@]}"; do
    if brew list --formula "$formula" >/dev/null 2>&1; then
      info "• $formula already installed"
    else
      brew install "$formula"
    fi
  done

  # Ensure the preferred python points to the new version for user scripts
  if [[ -x "$(brew --prefix python@3.12)/bin/python3" ]]; then
    mkdir -p "$HOME/.local/bin"
    ln -sfn "$(brew --prefix python@3.12)/bin/python3" "$HOME/.local/bin/python3" 2>/dev/null || true
  fi

  info "Ensuring pipx is on PATH"
  pipx ensurepath >/dev/null 2>&1 || true
}

brew_install_casks() {
  local casks=(
    nikitabobko/tap/aerospace
  )
  info "Installing Homebrew casks"
  for cask in "${casks[@]}"; do
    if brew list --cask "${cask##*/}" >/dev/null 2>&1; then
      info "• ${cask##*/} already installed"
    else
      brew install --cask "$cask"
    fi
  done
}

ensure_python_packages() {
  if ! command -v python3 >/dev/null 2>&1; then
    die "python3 was not installed correctly"
  fi
  info "Installing pynvim for Neovim remote plugins"
  python3 -m pip install --user --upgrade pip >/dev/null
  python3 -m pip install --user --upgrade pynvim >/dev/null
}

link_path() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
  info "Linked $target -> $source"
}

link_configs() {
  info "Linking configuration directories"
  mkdir -p "$CONFIG_HOME"

  link_path "$REPO_ROOT/nvim" "$CONFIG_HOME/nvim"
  link_path "$REPO_ROOT/aerospace" "$CONFIG_HOME/aerospace"
  link_path "$REPO_ROOT/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
}

prime_neovim() {
  if ! command -v nvim >/dev/null 2>&1; then
    die "Neovim is not installed"
  }
  info "Pre-installing Neovim plugins via Lazy.nvim"
  nvim --headless "+Lazy! sync" +qa || true
  nvim --headless "+MasonToolsUpdate" +qa || true
}

main() {
  ensure_xcode_clt
  ensure_homebrew
  eval "$(brew shellenv)"
  brew_install_formulae
  brew_install_casks
  ensure_python_packages
  link_configs
  prime_neovim
  info "All done! Open Neovim or AeroSpace to verify everything works."
}

main "$@"
