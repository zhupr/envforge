# =================================================================
# tmux + gpakosz framework
# =================================================================
info "🖥️  Setting up tmux..."

# Install tmux
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  # Prefer packaged .deb/.rpm, then build the bundled source tarball.
  for pkg in "$OFFLINE_DIR/bins"/tmux*.deb "$OFFLINE_DIR/bins"/tmux*.rpm; do
    [[ -f "$pkg" ]] && { sudo dpkg -i "$pkg" 2>/dev/null || sudo rpm -i "$pkg" 2>/dev/null || true; }
  done
  if ! command -v tmux &>/dev/null; then
    TMUX_SRC="$(ls "$OFFLINE_DIR/tmux"/tmux-*.tar.gz 2>/dev/null | head -n1 || true)"
    if [[ -n "$TMUX_SRC" ]]; then
      info "Building tmux from $TMUX_SRC"
      TMPDIR="$(mktemp -d)"
      if tar -xzf "$TMUX_SRC" -C "$TMPDIR" && (cd "$TMPDIR"/tmux-* && ./configure --prefix="$HOME/.local" && make -j"$(nproc)" && make install); then
        ok "tmux built from offline source"
      else
        warn "tmux source build failed (missing build deps?)"
      fi
      rm -rf "$TMPDIR"
    fi
  fi
  GPAKO=""; for f in "$OFFLINE_DIR/tmux"/gpakosz*.tar.gz; do [[ -f "$f" ]] && GPAKO="$f"; done
  if [[ -n "$GPAKO" ]]; then
    mkdir -p "$HOME/.tmux" && tar xzf "$GPAKO" -C "$HOME/.tmux" --strip-components=1 && ok "gpakosz offline installed"
  else
    warn "gpakosz tarball missing in $OFFLINE_DIR/tmux/ — skipping framework."
  fi
  # Allow the package manager as a last resort instead of hard-blocking.
  if command -v tmux &>/dev/null; then
    DO_TMUX_OFFLINE_DONE=true
  else
    warn "tmux still missing — attempting $PKG_MGR (may fail if truly offline)"
  fi
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
        TMUX_URL="$(api_asset_url tmux/tmux '^tmux-.*\.tar\.gz$')"
        if [[ -n "$TMUX_URL" ]]; then
          TMPDIR=$(mktemp -d)
          if download "$TMUX_URL" "$TMPDIR/tmux.tar.gz" &&
             (cd "$TMPDIR" && tar xzf tmux.tar.gz && cd tmux-* &&
              ./configure --prefix="$HOME/.local" && make -j"$(nproc)" && make install); then
            ok "tmux built from source"
          else
            warn "tmux source build failed"
          fi
          rm -rf "$TMPDIR"
        else
          warn "Could not resolve the tmux release asset (API rate limit?); keeping the apt version"
        fi
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
