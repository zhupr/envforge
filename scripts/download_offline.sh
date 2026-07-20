#!/usr/bin/env bash
# =================================================================
# Pre-download all dependencies for offline installation
#
# Run this on a machine WITH internet access:
#   ./scripts/download_offline.sh
#
# Then copy the offline/ directory to the target machine and run:
#   ./install.sh --offline
# =================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
OFFLINE_DIR="$DOTFILES_ROOT/offline"

mkdir -p "$OFFLINE_DIR"/{go,rust,nvim,tmux,conda,nvm,node}

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()   { echo -e "${GREEN}[OK]${NC}    $*"; }

# ---- Go ----
GO_VERSION="1.24.4"
ARCH="$(uname -m)"
OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$ARCH" in
  x86_64)  GO_ARCH="amd64" ;;
  aarch64|arm64) GO_ARCH="arm64" ;;
esac
GO_TAR="go${GO_VERSION}.${OS_NAME}-${GO_ARCH}.tar.gz"
if [[ ! -f "$OFFLINE_DIR/go/$GO_TAR" ]]; then
  info "Downloading Go $GO_VERSION..."
  curl -fsSL "https://go.dev/dl/$GO_TAR" -o "$OFFLINE_DIR/go/$GO_TAR"
  ok "Go: $OFFLINE_DIR/go/$GO_TAR"
else
  ok "Go already downloaded"
fi

# ---- Rust (rustup-init) ----
if [[ ! -f "$OFFLINE_DIR/rust/rustup-init" ]]; then
  info "Downloading rustup-init..."
  curl -fsSL "https://sh.rustup.rs" -o "$OFFLINE_DIR/rust/rustup-init"
  ok "Rust: $OFFLINE_DIR/rust/rustup-init"
else
  ok "Rust already downloaded"
fi

# ---- Neovim AppImage (Linux only) ----
if [[ "$OS_NAME" == "linux" ]]; then
  case "$ARCH" in
    x86_64) NVIM_FILE="nvim-linux-x86_64.appimage" ;;
    *)      NVIM_FILE="nvim-linux-arm64.appimage" ;;
  esac
  if [[ ! -f "$OFFLINE_DIR/nvim/$NVIM_FILE" ]]; then
    info "Downloading Neovim..."
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/$NVIM_FILE" \
      -o "$OFFLINE_DIR/nvim/$NVIM_FILE"
    chmod +x "$OFFLINE_DIR/nvim/$NVIM_FILE"
    ok "Neovim: $OFFLINE_DIR/nvim/$NVIM_FILE"
  fi
fi

# ---- tmux source ----
if [[ ! -f "$OFFLINE_DIR/tmux/tmux-3.5a.tar.gz" ]]; then
  info "Downloading tmux source..."
  curl -fsSL "https://github.com/tmux/tmux/releases/latest/download/tmux-3.5a.tar.gz" \
    -o "$OFFLINE_DIR/tmux/tmux-3.5a.tar.gz"
  ok "tmux: $OFFLINE_DIR/tmux/tmux-3.5a.tar.gz"
fi

# ---- gpakosz/.tmux ----
if [[ ! -f "$OFFLINE_DIR/tmux/gpakosz-tmux.tar.gz" ]]; then
  info "Downloading gpakosz/.tmux..."
  curl -fsSL "https://github.com/gpakosz/.tmux/archive/refs/heads/master.tar.gz" \
    -o "$OFFLINE_DIR/tmux/gpakosz-tmux.tar.gz"
  ok "gpakosz/.tmux: $OFFLINE_DIR/tmux/gpakosz-tmux.tar.gz"
fi

# ---- zimfw ----
if [[ ! -f "$OFFLINE_DIR/nvim/zimfw.zsh" ]]; then
  info "Downloading zimfw..."
  curl -fsSL "https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh" \
    -o "$OFFLINE_DIR/nvim/zimfw.zsh"
  ok "zimfw: $OFFLINE_DIR/nvim/zimfw.zsh"
fi

# ---- Miniconda ----
case "$(uname -s)-$ARCH" in
  Darwin-arm64)  CONDA_FILE="Miniconda3-latest-MacOSX-arm64.sh" ;;
  Darwin-x86_64) CONDA_FILE="Miniconda3-latest-MacOSX-x86_64.sh" ;;
  Linux-x86_64)  CONDA_FILE="Miniconda3-latest-Linux-x86_64.sh" ;;
  Linux-aarch64) CONDA_FILE="Miniconda3-latest-Linux-aarch64.sh" ;;
esac
if [[ ! -f "$OFFLINE_DIR/conda/$CONDA_FILE" ]]; then
  info "Downloading Miniconda..."
  curl -fsSL "https://repo.anaconda.com/miniconda/$CONDA_FILE" \
    -o "$OFFLINE_DIR/conda/$CONDA_FILE"
  ok "Miniconda: $OFFLINE_DIR/conda/$CONDA_FILE"
fi

# ---- Node.js (for offline nvm) ----
NODE_VERSION="v22.16.0"
case "$ARCH" in
  x86_64)  NODE_ARCH="x64" ;;
  arm64|aarch64) NODE_ARCH="arm64" ;;
esac
NODE_TAR="node-${NODE_VERSION}-${OS_NAME}-${NODE_ARCH}.tar.gz"
if [[ ! -f "$OFFLINE_DIR/node/$NODE_TAR" ]]; then
  info "Downloading Node.js $NODE_VERSION..."
  curl -fsSL "https://nodejs.org/dist/$NODE_VERSION/$NODE_TAR" \
    -o "$OFFLINE_DIR/node/$NODE_TAR"
  ok "Node.js: $OFFLINE_DIR/node/$NODE_TAR"
fi

# ---- vcpkg ----
if [[ ! -f "$OFFLINE_DIR/nvim/vcpkg.tar.gz" ]]; then
  info "Downloading vcpkg..."
  curl -fsSL "https://github.com/microsoft/vcpkg/archive/refs/heads/master.tar.gz" \
    -o "$OFFLINE_DIR/nvim/vcpkg.tar.gz"
  ok "vcpkg: $OFFLINE_DIR/nvim/vcpkg.tar.gz"
fi

echo ""
echo "========================================="
echo "  ✅ All downloads complete!"
echo "========================================="
echo ""
echo "Offline packages saved to: $OFFLINE_DIR"
du -sh "$OFFLINE_DIR"/*
echo ""
echo "Copy the entire dotfiles/ directory to the target machine."
