# =================================================================
# C++ toolchain: cmake, llvm (clangd/clang-format/clang-tidy), vcpkg
# =================================================================
info "⚙️  Setting up C++ toolchain..."

if [[ "${DO_OFFLINE:-false}" == true ]]; then
  VCPKG_TAR="$(ls "$OFFLINE_DIR/nvim"/vcpkg*.tar.gz "$OFFLINE_DIR/cpp"/vcpkg*.tar.gz 2>/dev/null | head -n1)"
  if [[ -n "$VCPKG_TAR" ]]; then
    mkdir -p "$(dirname "${VCPKG_ROOT:-$HOME/.local/share/vcpkg}")"
    mkdir -p "${VCPKG_ROOT:-$HOME/.local/share/vcpkg}"
    tar xzf "$VCPKG_TAR" -C "${VCPKG_ROOT:-$HOME/.local/share/vcpkg}" --strip-components=1
    ok "vcpkg offline installed"
  else
    warn "vcpkg tarball missing in offline/ — skipping vcpkg (offline mode)."
  fi
  ok "C++ system toolchain skipped offline (brew/apt needs network); use preinstalled clang/cmake or add to offline/bins/"
  DO_CPP_OFFLINE_DONE=true
fi
if [[ "${DO_CPP_OFFLINE_DONE:-false}" != true ]]; then
case "$PKG_MGR" in
  brew) brew install cmake llvm ;;
  apt)  sudo apt-get install -y cmake clang clangd clang-format clang-tidy llvm ;;
  dnf)  sudo dnf install -y cmake clang clang-tools-extra llvm ;;
esac
fi

# Symlink clang tools to ~/.local/bin (macOS: Homebrew doesn't add to PATH)
BINDIR="$HOME/.local/bin"
mkdir -p "$BINDIR"

if [[ "$PKG_MGR" == "brew" ]]; then
  LLVM_PREFIX="$(brew --prefix llvm)"
  for tool in clangd clang-format clang-tidy; do
    src="$LLVM_PREFIX/bin/$tool"
    dst="$BINDIR/$tool"
    if [[ -x "$src" ]]; then
      rm -f "$dst"
      ln -sfn "$src" "$dst"
      ok "$dst -> $src"
    fi
  done
fi

# Install vcpkg
VCPKG_ROOT="${VCPKG_ROOT:-$HOME/.local/share/vcpkg}"
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  [[ -d "$VCPKG_ROOT" ]] && ok "vcpkg already present (offline)" || warn "vcpkg missing (offline) — add $OFFLINE_DIR/nvim/vcpkg.tar.gz"
elif [[ ! -d "$VCPKG_ROOT" ]]; then
  info "Installing vcpkg..."
  mkdir -p "$(dirname "$VCPKG_ROOT")"
  if ! download "https://github.com/microsoft/vcpkg/archive/refs/heads/master.tar.gz" "/tmp/vcpkg.tar.gz"; then
    warn "vcpkg download failed (network) — skipping vcpkg, clang/cmake still work"
  else
    mkdir -p "$VCPKG_ROOT"
    tar xzf /tmp/vcpkg.tar.gz -C "$VCPKG_ROOT" --strip-components=1 || warn "vcpkg unpack failed"
    rm -f /tmp/vcpkg.tar.gz
    "$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics 2>/dev/null || warn "vcpkg bootstrap failed"
  fi
fi

ok "C++ toolchain ready (cmake, clangd, vcpkg)"
