# =================================================================
# tmux + gpakosz framework
# =================================================================
info "🖥️  Setting up tmux..."

# Install tmux
if ! command -v tmux &>/dev/null; then
  case "$PKG_MGR" in
    brew) brew install tmux ;;
    apt)
      sudo apt-get install -y tmux libevent-dev ncurses-dev build-essential bison
      # Build from source if apt version is too old (< 3.0)
      TMUX_VER=$(tmux -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo "0")
      if [[ "$(echo "$TMUX_VER < 3.0" | bc -l 2>/dev/null || echo 1)" == "1" ]]; then
        info "Building tmux from source for newer version..."
        TMPDIR=$(mktemp -d)
        download "https://github.com/tmux/tmux/releases/latest/download/tmux-3.5a.tar.gz" \
          "$TMPDIR/tmux.tar.gz"
        cd "$TMPDIR" && tar xzf tmux.tar.gz && cd tmux-* && \
          ./configure --prefix="$HOME/.local" && make -j"$(nproc)" && make install
        cd "$DOTFILES_ROOT"
        rm -rf "$TMPDIR"
      fi
      ;;
    dnf)
      sudo dnf install -y tmux
      ;;
  esac
fi

# Install gpakosz/.tmux framework
if [[ ! -d "$HOME/.tmux" ]]; then
  info "Cloning gpakosz/.tmux framework..."
  download "https://github.com/gpakosz/.tmux/archive/refs/heads/master.tar.gz" "/tmp/gpakosz-tmux.tar.gz"
  mkdir -p "$HOME/.tmux"
  tar xzf /tmp/gpakosz-tmux.tar.gz -C "$HOME/.tmux" --strip-components=1
  rm -f /tmp/gpakosz-tmux.tar.gz
  ok "gpakosz/.tmux installed"
fi

# Symlink
link_file "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_ROOT/config/tmux/tmux.conf.local" "$HOME/.tmux.conf.local"

ok "tmux configured"
