# =================================================================
# Neovim + LazyVim + Node.js (via nvm)
# =================================================================
info "📝 Setting up Neovim..."

# Install neovim
if ! command -v nvim &>/dev/null; then
  case "$PKG_MGR" in
    brew) brew install neovim ;;
    apt)
      # Prefer AppImage for latest version (company machines often have old apt repos)
      info "Installing Neovim AppImage..."
      NVIM_DIR="$HOME/.local/bin"
      mkdir -p "$NVIM_DIR"
      if [[ "$(uname -m)" == "x86_64" ]]; then
        download "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage" \
          "$NVIM_DIR/nvim" && chmod +x "$NVIM_DIR/nvim"
      else
        download "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage" \
          "$NVIM_DIR/nvim" && chmod +x "$NVIM_DIR/nvim"
      fi
      # Fallback to apt if AppImage fails
      if ! command -v nvim &>/dev/null && ! [[ -x "$NVIM_DIR/nvim" ]]; then
        warn "AppImage failed, trying apt..."
        sudo apt-get install -y neovim
      fi
      ;;
    dnf) sudo dnf install -y neovim ;;
  esac
fi

# Install Node.js via nvm (needed for some LSP servers, Mason, etc.)
if ! command -v node &>/dev/null; then
  info "Installing Node.js via nvm..."
  export NVM_DIR="$HOME/.nvm"
  NVM_MIRROR="${NVM_MIRROR:-}"
  NVM_NODEJS_ORG_MIRROR="${NVM_NODEJS_ORG_MIRROR:-}"

  if [[ ! -d "$NVM_DIR" ]]; then
    download "https://github.com/nvm-sh/nvm/releases/latest/download/nvm.sh" "/tmp/nvm-install.sh" && \
      bash /tmp/nvm-install.sh
  fi

  # Source nvm
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

  # Install latest LTS node
  if [[ -n "$NVM_NODEJS_ORG_MIRROR" ]]; then
    NVM_NODEJS_ORG_MIRROR="$NVM_NODEJS_ORG_MIRROR" nvm install --lts
  else
    nvm install --lts
  fi
  nvm alias default 'lts/*'
  ok "Node.js installed via nvm"
fi

# Install ripgrep, fd (nvim dependencies)
case "$PKG_MGR" in
  brew) brew install ripgrep fd ;;
  apt)  sudo apt-get install -y ripgrep fd-find ;;
  dnf)  sudo dnf install -y ripgrep fd-find ;;
esac

# Symlink nvim config
if [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
  warn "Backing up existing nvim config"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
fi
link_file "$DOTFILES_ROOT/config/nvim" "$HOME/.config/nvim"

ok "Neovim configured (plugins auto-install on first launch)"
