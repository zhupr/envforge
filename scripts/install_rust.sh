# =================================================================
# Rust toolchain (rustup + rust-analyzer)
# =================================================================
info "🦀 Setting up Rust..."

if [[ "${DO_OFFLINE:-false}" == true ]]; then
  # A rustup-init script alone is useless offline: it downloads the toolchain
  # from static.rust-lang.org. download_offline.sh therefore also packs
  # ~/.rustup + ~/.cargo into rust-toolchain.tar.gz.
  RUST_BUNDLE="$OFFLINE_DIR/rust/rust-toolchain.tar.gz"
  if [[ -f "$RUST_BUNDLE" ]]; then
    info "Restoring Rust toolchain from $RUST_BUNDLE"
    tar -xzf "$RUST_BUNDLE" -C "$HOME" && ok "Rust toolchain restored (offline)"
    export PATH="$HOME/.cargo/bin:$PATH"
    [[ -x "$HOME/.cargo/bin/rustc" || -x "$HOME/.cargo/bin/cargo" ]] && DO_RUST_OFFLINE_DONE=true
  elif [[ -f "$OFFLINE_DIR/rust/rustup-init" && -d "$OFFLINE_DIR/rust/dist" ]]; then
    # Local dist mirror: rustup-init can install without the internet.
    chmod +x "$OFFLINE_DIR/rust/rustup-init"
    RUSTUP_DIST_SERVER="file://$OFFLINE_DIR/rust/dist" \
      "$OFFLINE_DIR/rust/rustup-init" -y --no-modify-path --default-toolchain stable \
      && DO_RUST_OFFLINE_DONE=true
    export PATH="$HOME/.cargo/bin:$PATH"
  else
    warn "Rust offline bundle missing ($OFFLINE_DIR/rust/rust-toolchain.tar.gz)."
    warn "  Run ./scripts/download_offline.sh on a networked machine to create it."
    warn "  Falling back to the network installer."
  fi
fi
if [[ "${DO_RUST_OFFLINE_DONE:-false}" == true ]]; then
  : # offline already handled
elif ! command -v rustc &>/dev/null; then
  info "Installing Rust via rustup..."
  # Use mirror if set
  RUSTUP_DIST_SERVER="${RUSTUP_DIST_SERVER:-}"
  RUSTUP_UPDATE_ROOT="${RUSTUP_UPDATE_ROOT:-}"

  download "https://sh.rustup.rs" "/tmp/rustup-init.sh"
  if [[ -s /tmp/rustup-init.sh ]]; then
    # -y = non-interactive, --no-modify-path = we handle PATH ourselves
    RUSTUP_DIST_SERVER="${RUSTUP_DIST_SERVER:-}" \
    RUSTUP_UPDATE_ROOT="${RUSTUP_UPDATE_ROOT:-}" \
      sh /tmp/rustup-init.sh -y --no-modify-path || warn "rustup install failed"
    rm -f /tmp/rustup-init.sh
    export PATH="$HOME/.cargo/bin:$PATH"
    command -v rustc &>/dev/null && ok "Rust installed" || warn "Rust not installed (network?)"
  else
    warn "Could not download the rustup installer; skipping Rust"
  fi
else
  ok "Rust already installed ($(rustc --version 2>/dev/null))"
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Configure cargo mirror for China
if [[ -n "${CARGO_REGISTRIES_CRATES_IO_INDEX:-}" ]]; then
  mkdir -p "$HOME/.cargo"
  # Only add if not already configured
  if ! grep -q "sparse-index" "$HOME/.cargo/config.toml" 2>/dev/null; then
    cat >> "$HOME/.cargo/config.toml" << CARGO_TOML

[source.crates-io]
replace-with = "ustc"

[source.ustc]
registry = "sparse+${CARGO_REGISTRIES_CRATES_IO_INDEX}"
CARGO_TOML
    ok "Cargo mirror configured"
  fi
fi

# Install rust-analyzer (needed by LazyVim for Rust support)
if ! command -v rust-analyzer &>/dev/null; then
  info "Installing rust-analyzer..."
  # rustup component (preferred)
  rustup component add rust-analyzer 2>/dev/null || {
    # Fallback: resolve the release asset for this platform
    case "$(uname -s)-$(uname -m)" in
      Darwin-arm64)  RA_PAT="rust-analyzer-aarch64-apple-darwin\.gz$" ;;
      Darwin-x86_64) RA_PAT="rust-analyzer-x86_64-apple-darwin\.gz$" ;;
      Linux-aarch64|Linux-arm64) RA_PAT="rust-analyzer-aarch64-unknown-linux-gnu\.gz$" ;;
      Linux-x86_64)  RA_PAT="rust-analyzer-x86_64-unknown-linux-gnu\.gz$" ;;
      *)             RA_PAT="" ;;
    esac
    RA_URL=""
    [[ -n "$RA_PAT" ]] && RA_URL="$(api_asset_url rust-lang/rust-analyzer "$RA_PAT")"
    if [[ -n "$RA_URL" ]] && download "$RA_URL" "/tmp/rust-analyzer.gz"; then
      gunzip -f /tmp/rust-analyzer.gz
      chmod +x /tmp/rust-analyzer
      mkdir -p "$HOME/.cargo/bin"
      mv /tmp/rust-analyzer "$HOME/.cargo/bin/rust-analyzer"
      ok "rust-analyzer installed from release asset"
    else
      warn "rust-analyzer not installed (rustup component and asset download both failed)"
    fi
  }
fi

ok "Rust toolchain ready"
