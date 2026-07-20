# =================================================================
# Rust toolchain (rustup + rust-analyzer)
# =================================================================
info "🦀 Setting up Rust..."

if ! command -v rustc &>/dev/null; then
  info "Installing Rust via rustup..."
  # Use mirror if set
  RUSTUP_DIST_SERVER="${RUSTUP_DIST_SERVER:-}"
  RUSTUP_UPDATE_ROOT="${RUSTUP_UPDATE_ROOT:-}"

  download "https://sh.rustup.rs" "/tmp/rustup-init.sh"
  # -y = non-interactive, --no-modify-path = we handle PATH ourselves
  RUSTUP_DIST_SERVER="${RUSTUP_DIST_SERVER:-}" \
  RUSTUP_UPDATE_ROOT="${RUSTUP_UPDATE_ROOT:-}" \
    sh /tmp/rustup-init.sh -y --no-modify-path
  rm -f /tmp/rustup-init.sh

  export PATH="$HOME/.cargo/bin:$PATH"
  ok "Rust installed"
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
    # Fallback: download binary
    RA_ARCH="$(uname -m)"
    [[ "$RA_ARCH" == "arm64" ]] && RA_ARCH="aarch64"
    download "https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-${RA_ARCH}-apple-darwin.gz" \
      "/tmp/rust-analyzer.gz" 2>/dev/null || \
    download "https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz" \
      "/tmp/rust-analyzer.gz" 2>/dev/null || true
    if [[ -f "/tmp/rust-analyzer.gz" ]]; then
      gunzip -f /tmp/rust-analyzer.gz
      chmod +x /tmp/rust-analyzer
      mv /tmp/rust-analyzer "$HOME/.cargo/bin/rust-analyzer"
    fi
  }
fi

ok "Rust toolchain ready"
