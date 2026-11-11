# =================================================================
# Zsh + zimfw + powerlevel10k
# =================================================================
info "🐚 Setting up Zsh..."

# Install zsh
if ! command -v zsh &>/dev/null; then
  case "$PKG_MGR" in
    brew) brew install zsh ;;
    apt)  sudo apt-get install -y zsh ;;
    dnf)  sudo dnf install -y zsh ;;
  esac
fi

# Symlink zsh configs
link_file "$DOTFILES_ROOT/config/zsh/.zshrc"  "$HOME/.zshrc"
link_file "$DOTFILES_ROOT/config/zsh/.zimrc"  "$HOME/.zimrc"

# Symlink p10k config if exists in repo
if [[ -f "$DOTFILES_ROOT/config/zsh/.p10k.zsh" ]]; then
  link_file "$DOTFILES_ROOT/config/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
fi

# Install zimfw
ZIM_HOME="${ZDOTDIR:-$HOME}/.zim"
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  ZIMFW_SRC="$(ls "$OFFLINE_DIR/zsh"/zimfw.zsh "$OFFLINE_DIR/nvim"/zimfw.zsh 2>/dev/null | head -n1 || true)"
  if [[ -n "$ZIMFW_SRC" ]]; then
    mkdir -p "$ZIM_HOME" && copy_tree "$ZIMFW_SRC" "$ZIM_HOME/zimfw.zsh" 2>/dev/null || cp "$ZIMFW_SRC" "$ZIM_HOME/zimfw.zsh"
    ok "zimfw offline copied from $ZIMFW_SRC"
  else
    warn "zimfw missing in offline/ — skipping zimfw (offline mode)."
  fi
elif [[ ! -e "$ZIM_HOME/zimfw.zsh" ]]; then
  info "Installing zimfw..."
  # curl -o cannot create parent directories; ~/.zim may not exist yet.
  mkdir -p "$ZIM_HOME"
  # zimfw has no release assets; master's zimfw.zsh is the installer.
  download "https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh" \
    "$ZIM_HOME/zimfw.zsh" || {
    warn "Download failed. Check your network or set GITHUB_MIRROR."
    warn "  export GITHUB_MIRROR=https://ghfast.top/https://github.com"
  }
fi

# Install zimfw modules (powerlevel10k, fzf-tab, syntax-highlighting, etc.)
if [[ -e "$ZIM_HOME/zimfw.zsh" ]]; then
  info "Installing zimfw modules..."
  zsh -c "ZIM_HOME=$ZIM_HOME; source $ZIM_HOME/zimfw.zsh install" 2>/dev/null || true
fi

# Set zsh as default shell (if not already)
if [[ "$SHELL" != "$(which zsh)" ]]; then
  info "Setting zsh as default shell..."
  ZSH_PATH="$(which zsh)"
  if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_PATH" 2>/dev/null || warn "Run manually: chsh -s $ZSH_PATH"
fi

ok "Zsh configured"
