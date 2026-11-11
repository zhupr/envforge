# =================================================================
# Neovim + LazyVim + Node.js (via nvm)
# =================================================================
info "📝 Setting up Neovim..."

# Install neovim
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  NVIM_BIN="$HOME/.local/bin/nvim"
  mkdir -p "$HOME/.local/bin"
  APPIMG="$(ls "$OFFLINE_DIR/nvim"/*.appimage 2>/dev/null | head -n1 || true)"
  ARCHIVE="$(ls "$OFFLINE_DIR/nvim"/*.tar.gz 2>/dev/null | grep -v vcpkg | head -n1 || true)"
  if [[ -n "$APPIMG" ]]; then
    cp "$APPIMG" "$NVIM_BIN" && chmod +x "$NVIM_BIN"
    ok "Neovim offline AppImage installed"
  elif [[ -n "$ARCHIVE" ]]; then
    # nvim-linux-<arch>.tar.gz / nvim-macos-<arch>.tar.gz (macOS is supported now)
    NVIM_TMP="$(mktemp -d)"
    if tar -xzf "$ARCHIVE" -C "$NVIM_TMP" 2>/dev/null; then
      cp -R "$NVIM_TMP"/nvim-*/. "$HOME/.local/" 2>/dev/null || true
      [[ -x "$HOME/.local/bin/nvim" ]] || cp "$NVIM_TMP"/nvim-*/bin/nvim "$NVIM_BIN" 2>/dev/null || true
      chmod +x "$NVIM_BIN" 2>/dev/null || true
    fi
    rm -rf "$NVIM_TMP"
    if [[ -x "$NVIM_BIN" ]]; then
      ok "Neovim offline archive installed from $ARCHIVE"
    else
      warn "Neovim archive $ARCHIVE could not be unpacked into ~/.local/bin/nvim"
    fi
  else
    warn "Neovim package missing in $OFFLINE_DIR/nvim/ — will try the network path instead."
  fi

  NODE_TAR="$(ls "$OFFLINE_DIR/node"/node-*.tar.gz 2>/dev/null | head -n1 || true)"
  if [[ -n "$NODE_TAR" ]]; then
    mkdir -p "$HOME/.local" && tar -xzf "$NODE_TAR" -C "$HOME/.local" --strip-components=1 2>/dev/null || unpack_tar "$NODE_TAR" "$HOME/.local/node"
    ok "Node offline installed from $NODE_TAR"
  fi

  # Only claim "done" when a binary actually exists; otherwise fall through to
  # the online path (brew/apt) instead of silently skipping Neovim.
  if [[ -x "$HOME/.local/bin/nvim" ]] || command -v nvim &>/dev/null; then
    DO_NVIM_OFFLINE_DONE=true
  fi
fi
if [[ "${DO_NVIM_OFFLINE_DONE:-false}" == true ]]; then
  : # offline handled
elif ! command -v nvim &>/dev/null && ! [[ -x "$HOME/.local/bin/nvim" ]]; then
  case "$PKG_MGR" in
    brew) brew install neovim ;;
    apt)
      # Prefer AppImage for latest version (company machines often have old apt repos)
      info "Installing Neovim AppImage..."
      NVIM_DIR="$HOME/.local/bin"
      mkdir -p "$NVIM_DIR"
      NVIM_TARGET="$([[ "$(uname -m)" == "x86_64" ]] && echo x86_64 || echo arm64)"
      NVIM_URL="$(api_asset_url neovim/neovim "^nvim-linux-${NVIM_TARGET}\.appimage$")"
      [[ -z "$NVIM_URL" ]] && NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_TARGET}.appimage"
      download "$NVIM_URL" "$NVIM_DIR/nvim" && chmod +x "$NVIM_DIR/nvim"
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
    # nvm publishes no release asset named nvm.sh; use the git installer.
    download "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" "/tmp/nvm-install.sh" &&
      bash /tmp/nvm-install.sh || warn "nvm install failed, skipping Node"
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
