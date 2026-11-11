# =================================================================
# Modern CLI tools + Nerd Font
# Complete list: eza, bat, ripgrep, fzf, fd-find, yazi, tree, htop,
#                lazygit, wget, jq, Nerd Font
# =================================================================
info "📦 Installing modern CLI tools..."

install_pkg() {
  local brew_name="$1" apt_name="${2:-$1}" cmd_name="${3:-$1}"
  if command -v "$cmd_name" &>/dev/null; then
    ok "$cmd_name already installed"
    return 0
  fi
  if [[ "${DO_OFFLINE:-false}" == true ]]; then
    # Offline: prefer packaged artifacts in offline/bins/ (plain binary or archive)
    if install_offline_bin "$cmd_name" "$HOME/.local/bin"; then
      ok "$cmd_name offline installed"
      return 0
    fi
    warn "$cmd_name not in offline/bins/ — falling back to $PKG_MGR (needs network)"
  fi
  case "$PKG_MGR" in
    brew) brew install "$brew_name" ;;
    apt)
      sudo apt-get update 2>/dev/null || true
      if apt-cache show "$apt_name" >/dev/null 2>&1; then
        sudo apt-get install -y "$apt_name" 2>/dev/null || warn "$apt_name apt-get install failed, fallback"
      else
        warn "$apt_name not in apt repo, will install via binary fallback"
        case "$cmd_name" in
          eza) sudo apt-get install -y eza 2>/dev/null || (command -v cargo &>/dev/null && cargo install eza || warn "eza: no apt pkg, cargo unavailable") ;;
          yazi) sudo apt-get install -y yazi 2>/dev/null || warn "yazi: skip (no apt pkg) — conf still linked" ;;
          glow) sudo apt-get install -y glow 2>/dev/null || warn "glow: skip fallback" ;;
          *) warn "skip $cmd_name (no apt pkg)" ;;
        esac
      fi
      ;;
    dnf)  sudo dnf install -y "$brew_name" || sudo dnf install -y "$apt_name" ;;
    yum)  sudo yum install -y "$apt_name" ;;
  esac
  ok "$cmd_name installed"
}

install_pkg eza       eza       eza
install_pkg bat       bat       bat
install_pkg ripgrep   ripgrep   rg
install_pkg fzf       fzf       fzf
install_pkg fd        fd-find   fd
install_pkg yazi      yazi      yazi
install_pkg tree      tree      tree
install_pkg htop      htop      htop
install_pkg lazygit   lazygit   lazygit
install_pkg wget      wget      wget
install_pkg jq        jq        jq
install_pkg glow      glow      glow

# Ubuntu: fd is named fdfind, create symlink
if [[ "$PKG_MGR" == "apt" ]] && ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
  ok "Symlinked fdfind -> fd"
fi

# Ubuntu: bat is named batcat, create symlink
if [[ "$PKG_MGR" == "apt" ]] && ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
  sudo ln -sf "$(which batcat)" /usr/local/bin/bat
  ok "Symlinked batcat -> bat"
fi

# fzf keybindings (Ctrl+R, Ctrl+T, Alt+C)
if [[ "$PKG_MGR" == "brew" ]]; then
  "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish 2>/dev/null || true
fi

# Nerd Font (icons for eza/bat/nvim/tmux statusline)
info "🔤 Installing Nerd Font..."
NERD_FONT_INSTALLED=false

if [[ -d "$HOME/Library/Fonts" ]] && ls "$HOME/Library/Fonts/"*NerdFont* &>/dev/null; then
  NERD_FONT_INSTALLED=true
  ok "Nerd Font already installed"
elif [[ -d "$HOME/.local/share/fonts" ]] && ls "$HOME/.local/share/fonts/"*NerdFont* &>/dev/null; then
  NERD_FONT_INSTALLED=true
  ok "Nerd Font already installed"
fi

if [[ "$NERD_FONT_INSTALLED" == false ]]; then
  FONT_ZIP="/tmp/MesloLGLNerdFont.zip"
  OFFLINE_FONT="$(_offline_find fonts '*' 2>/dev/null | head -n1 || true)"

  if [[ -n "${OFFLINE_FONT:-}" && -f "$OFFLINE_FONT" ]]; then
    info "Using offline font package $OFFLINE_FONT"
    mkdir -p "$HOME/.local/share/fonts"
    unzip -oq "$OFFLINE_FONT" -d "$HOME/.local/share/fonts" >/dev/null 2>&1 || \
      warn "Could not unpack $OFFLINE_FONT"
    fc-cache -fv >/dev/null 2>&1 || true
    ok "Nerd Font installed from offline package"
  else
    case "$PKG_MGR" in
      brew)
        brew install --cask font-meslo-lg-nerd-font 2>/dev/null || \
          warn "Font install via brew failed, retry: brew install --cask font-meslo-lg-nerd-font"
        ok "Meslo LG Nerd Font installed (via Homebrew)"
        ;;
      *)
        # Resolve the current release instead of pinning a tag that may 404.
        FONT_URL="$(api_asset_url ryanoasis/nerd-fonts 'MesloLGLNerdFont\.zip')"
        if [[ -n "$FONT_URL" ]] && download "$FONT_URL" "$FONT_ZIP"; then
          mkdir -p "$HOME/.local/share/fonts"
          unzip -oq "$FONT_ZIP" -d "$HOME/.local/share/fonts" >/dev/null 2>&1
          fc-cache -fv >/dev/null 2>&1 || true
          rm -f "$FONT_ZIP"
          ok "Meslo LG Nerd Font installed"
        else
          warn "Font download failed. Manual install:"
          warn "  1. https://github.com/ryanoasis/nerd-fonts/releases"
          warn "  2. Download MesloLGLNerdFont.zip"
          warn "  3. Unzip into ~/.local/share/fonts/"
        fi
        ;;
    esac
  fi
fi

echo ""
echo "  ⚠️  Set your terminal font to: MesloLGL Nerd Font"
echo "     iTerm2:         Profiles → Text → Font → MesloLGL Nerd Font"
echo "     Kitty:          font_family MesloLGL Nerd Font (kitty.conf)"
echo "     WezTerm:        auto-detects Nerd Font"
echo "     macOS Terminal: no Nerd Font support — use iTerm2/Kitty/WezTerm"
echo ""

# Symlink ripgrep config
link_file "$DOTFILES_ROOT/config/zsh/.ripgreprc" "$HOME/.ripgreprc"

# Symlink yazi config
mkdir -p "$HOME/.config/yazi"
link_file "$DOTFILES_ROOT/config/yazi/yazi.toml"   "$HOME/.config/yazi/yazi.toml"
link_file "$DOTFILES_ROOT/config/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"

ok "All CLI tools ready"
