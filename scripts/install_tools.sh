# =================================================================
# Modern CLI tools
# Complete list: eza, bat, ripgrep, fzf, fd-find, yazi, tree, htop,
#                lazygit, wget, jq
# =================================================================
info "📦 Installing modern CLI tools..."

install_pkg() {
  local brew_name="$1" apt_name="${2:-$1}" cmd_name="${3:-$1}"
  if command -v "$cmd_name" &>/dev/null; then
    ok "$cmd_name already installed"
    return 0
  fi
  case "$PKG_MGR" in
    brew) brew install "$brew_name" ;;
    apt)  sudo apt-get install -y "$apt_name" ;;
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

# Symlink ripgrep config
link_file "$DOTFILES_ROOT/config/zsh/.ripgreprc" "$HOME/.ripgreprc"

# Symlink yazi config
mkdir -p "$HOME/.config/yazi"
link_file "$DOTFILES_ROOT/config/yazi/yazi.toml"   "$HOME/.config/yazi/yazi.toml"
link_file "$DOTFILES_ROOT/config/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"

ok "All CLI tools ready"
