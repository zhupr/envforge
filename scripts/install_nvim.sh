# =================================================================
# Neovim + LazyVim + Node.js (via nvm)
# =================================================================
info "📝 Setting up Neovim..."

# Install neovim
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  APPIMG="$(ls "$OFFLINE_DIR/nvim"/*.appimage 2>/dev/null | head -n1)"
  if [[ -n "$APPIMG" ]]; then
    mkdir -p "$HOME/.local/bin" && cp "$APPIMG" "$HOME/.local/bin/nvim" && chmod +x "$HOME/.local/bin/nvim"
    ok "Neovim offline AppImage installed"
  else
    warn "Neovim AppImage missing in $OFFLINE_DIR/nvim/ — skipping nvim binary (offline mode)."
  fi
  NODE_TAR="$(ls "$OFFLINE_DIR/node"/node-*.tar.gz 2>/dev/null | head -n1)"
  if [[ -n "$NODE_TAR" ]]; then
    mkdir -p "$HOME/.local" && tar -xzf "$NODE_TAR" -C "$HOME/.local" --strip-components=1 2>/dev/null || unpack_tar "$NODE_TAR" "$HOME/.local/node"
    ok "Node offline installed from $NODE_TAR"
  fi
  DO_NVIM_OFFLINE_DONE=true
fi
if [[ "${DO_NVIM_OFFLINE_DONE:-false}" == true ]]; then
  : # offline handled
elif ! command -v nvim &>/dev/null; then
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
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  command -v node &>/dev/null && ok "Node already present (offline)" || warn "Node missing (offline) — add $OFFLINE_DIR/node/node-*.tar.gz"
elif ! command -v node &>/dev/null; then
  info "Installing Node.js via nvm..."
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -d "$NVM_DIR" ]]; then
    download "https://github.com/nvm-sh/nvm/releases/latest/download/nvm.sh" "/tmp/nvm-install.sh" && bash /tmp/nvm-install.sh || warn "nvm install failed, skipping Node"
  fi
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || true
  if command -v nvm &>/dev/null; then
    if [[ -n "${NVM_NODEJS_ORG_MIRROR:-}" ]]; then
      NVM_NODEJS_ORG_MIRROR="$NVM_NODEJS_ORG_MIRROR" nvm install --lts || true
    else
      nvm install --lts || true
    fi
    nvm alias default 'lts/*' 2>/dev/null || true
    ok "Node.js installed via nvm"
  else
    warn "nvm not available, Node skipped (LazyVim needs node manually)"
  fi
fi

# Install ripgrep, fd (nvim dependencies)
if [[ "${DO_OFFLINE:-false}" != true ]]; then
case "$PKG_MGR" in
  brew) brew install ripgrep fd ;;
  apt)  sudo apt-get install -y ripgrep fd-find ;;
  dnf)  sudo dnf install -y ripgrep fd-find ;;
esac
fi

# Symlink nvim config
if [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
  warn "Backing up existing nvim config"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
fi
link_file "$DOTFILES_ROOT/config/nvim" "$HOME/.config/nvim"

ok "Neovim configured (plugins auto-install on first launch)"
