# =================================================================
# C++ toolchain: cmake, llvm (clangd/clang-format/clang-tidy), vcpkg
# =================================================================
info "⚙️  Setting up C++ toolchain..."

case "$PKG_MGR" in
  brew) brew install cmake llvm ;;
  apt)  sudo apt-get install -y cmake clang clangd clang-format clang-tidy llvm ;;
  dnf)  sudo dnf install -y cmake clang clang-tools-extra llvm ;;
esac

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
if [[ ! -d "$VCPKG_ROOT" ]]; then
  info "Installing vcpkg..."
  mkdir -p "$(dirname "$VCPKG_ROOT")"
  download "https://github.com/microsoft/vcpkg/archive/refs/heads/master.tar.gz" "/tmp/vcpkg.tar.gz"
  mkdir -p "$VCPKG_ROOT"
  tar xzf /tmp/vcpkg.tar.gz -C "$VCPKG_ROOT" --strip-components=1
  rm -f /tmp/vcpkg.tar.gz
  "$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics 2>/dev/null || warn "vcpkg bootstrap failed"
fi

ok "C++ toolchain ready (cmake, clangd, vcpkg)"
