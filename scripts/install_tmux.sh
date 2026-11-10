# =================================================================
# tmux + gpakosz framework
# =================================================================
info "🖥️  Setting up tmux..."

# Install tmux
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  # Copy locally packaged .deb/.rpm or prebuilt binaries from offline/bins/
  for pkg in "$OFFLINE_DIR/bins"/tmux*.deb "$OFFLINE_DIR/bins"/tmux*.rpm; do
    [[ -f "$pkg" ]] && sudo dpkg -i "$pkg" 2>/dev/null || sudo rpm -i "$pkg" 2>/dev/null || true
  done
  GPAKO=""; for f in "$OFFLINE_DIR/tmux"/gpakosz*.tar.gz; do [[ -f "$f" ]] && GPAKO="$f"; done
  if [[ -n "$GPAKO" ]]; then
    mkdir -p "$HOME/.tmux" && tar xzf "$GPAKO" -C "$HOME/.tmux" --strip-components=1 && ok "gpakosz offline installed"
  else
    warn "gpakosz tarball missing in $OFFLINE_DIR/tmux/ — skipping framework (offline mode)."
  fi
  DO_TMUX_OFFLINE_DONE=true
fi
if [[ "${DO_TMUX_OFFLINE_DONE:-false}" == true ]]; then
  : # offline handled
elif ! command -v tmux &>/dev/null; then
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
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  [[ -d "$HOME/.tmux" ]] && ok "gpakosz/.tmux already present (offline)" || warn "gpakosz missing (offline) — run online once or add $OFFLINE_DIR/tmux/gpakosz*.tar.gz"
elif [[ ! -d "$HOME/.tmux" ]]; then
  info "Cloning gpakosz/.tmux framework..."
  if ! download "https://github.com/gpakosz/.tmux/archive/refs/heads/master.tar.gz" "/tmp/gpakosz-tmux.tar.gz"; then
    warn "gpakosz download failed (network) — skipping framework, tmux binary still works"
  else
    mkdir -p "$HOME/.tmux"
    tar xzf /tmp/gpakosz-tmux.tar.gz -C "$HOME/.tmux" --strip-components=1 || warn "gpakosz unpack failed"
    rm -f /tmp/gpakosz-tmux.tar.gz
    ok "gpakosz/.tmux installed"
  fi
fi

# Symlink (only if framework landed)
[[ -f "$HOME/.tmux/.tmux.conf" ]] && link_file "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf" || warn "Skipping ~/.tmux.conf symlink (framework not installed)"
link_file "$DOTFILES_ROOT/config/tmux/tmux.conf.local" "$HOME/.tmux.conf.local"

ok "tmux configured"
