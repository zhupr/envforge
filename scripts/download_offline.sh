#!/usr/bin/env bash
# =================================================================
# Pre-download all dependencies for offline installation
#
# Run on a machine WITH internet access:
#   ./scripts/download_offline.sh
#
# Then copy the whole dotfiles/ directory to the target machine and run:
#   ./install.sh --offline            # installs everything
#   ./install.sh --offline --tools    # or a subset
#
# Asset names are resolved through the GitHub API for the latest release, so
# nothing here hard-codes a version into a /latest/download/ URL.
# Behind a proxy: export HTTPS_PROXY=http://127.0.0.1:7890
# =================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
OFFLINE_DIR="$DOTFILES_ROOT/offline"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()   { echo -e "${GREEN}[OK]${NC}    $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }

mkdir -p "$OFFLINE_DIR"/{go,rust,nvim,tmux,zsh,conda,nvm,node,herdr,omp,bins,glow,fonts}

# shellcheck source=/dev/null
source "$SCRIPT_DIR/offline.sh"   # api_asset_url / api_latest_tag

ARCH="$(uname -m)"
case "$(uname -s)" in
  Darwin) OS_NAME="darwin";  OS_LABEL="Darwin" ;;
  Linux)  OS_NAME="linux";   OS_LABEL="Linux" ;;
  *) warn "Unsupported OS $(uname -s)"; exit 1 ;;
esac
case "$ARCH" in
  x86_64)  GO_ARCH="amd64"; NODE_ARCH="x64";   BIN_ARCH="x86_64" ;;
  aarch64|arm64) GO_ARCH="arm64"; NODE_ARCH="arm64"; BIN_ARCH="aarch64" ;;
  *) warn "Unsupported arch $ARCH"; exit 1 ;;
esac

# fetch <url> <dest>  -> downloads atomically, returns non-zero on failure
fetch() {
  local url="$1" dest="$2"
  [[ -n "$url" ]] || return 1
  mkdir -p "$(dirname "$dest")"
  if curl -fL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 900 \
      -o "$dest.part" "$url" 2>/dev/null; then
    mv "$dest.part" "$dest"
    return 0
  fi
  rm -f "$dest.part"
  return 1
}

# dl_asset <owner/repo> <regex> <dest>  -> resolves the latest asset name
dl_asset() {
  local repo="$1" pat="$2" dest="$3"
  [[ -f "$dest" ]] && { ok "$(basename "$dest") already present"; return 0; }
  local url; url="$(api_asset_url "$repo" "$pat")"
  if [[ -z "$url" ]]; then
    warn "No asset matching /$pat/ in $repo latest release"
    return 1
  fi
  if fetch "$url" "$dest"; then
    ok "$(basename "$dest")  <- $(basename "$url")"
  else
    warn "Download failed: $url"
    return 1
  fi
}

# ---- Go (go.dev hosts the tarballs; GitHub releases carry no assets) ----
GO_VER="$(curl -fsSL --connect-timeout 10 https://go.dev/VERSION?m=text 2>/dev/null | head -n1)"
GO_VER="${GO_VER:-go1.24.4}"
GO_TAR="${GO_VER}.${OS_NAME}-${GO_ARCH}.tar.gz"
if [[ ! -f "$OFFLINE_DIR/go/$GO_TAR" ]]; then
  fetch "https://go.dev/dl/$GO_TAR" "$OFFLINE_DIR/go/$GO_TAR" && ok "go: $GO_TAR" || warn "Go download failed ($GO_TAR)"
fi

# ---- Rust: rustup-init + a portable toolchain bundle ----
RUST_BUNDLE="$OFFLINE_DIR/rust/rust-toolchain.tar.gz"
if [[ ! -f "$OFFLINE_DIR/rust/rustup-init" ]]; then
  fetch "https://sh.rustup.rs" "$OFFLINE_DIR/rust/rustup-init" && ok "rustup-init saved"
fi
if [[ ! -f "$RUST_BUNDLE" && -f "$OFFLINE_DIR/rust/rustup-init" ]]; then
  info "Packing a Rust toolchain bundle (this downloads ~300MB once)"
  BUNDLE="$(mktemp -d)"
  if chmod +x "$OFFLINE_DIR/rust/rustup-init" &&
     RUSTUP_HOME="$BUNDLE/.rustup" CARGO_HOME="$BUNDLE/.cargo" \
       "$OFFLINE_DIR/rust/rustup-init" -y --no-modify-path --profile minimal --default-toolchain stable >/dev/null 2>&1; then
    # rust-analyzer is needed by LazyVim
    RUSTUP_HOME="$BUNDLE/.rustup" CARGO_HOME="$BUNDLE/.cargo" \
      "$BUNDLE/.cargo/bin/rustup" component add rust-analyzer >/dev/null 2>&1 || true
    tar -czf "$RUST_BUNDLE" -C "$BUNDLE" .rustup .cargo 2>/dev/null && ok "rust: rust-toolchain.tar.gz"
  else
    warn "Could not build the Rust toolchain bundle (network?)"
  fi
  rm -rf "$BUNDLE"
fi

# ---- Neovim (linux appimage + tarball, macOS tarball) ----
# Release assets are named nvim-macos-<arm64|x86_64>.tar.gz / nvim-linux-<...>.
NVIM_OS="$OS_NAME"; [[ "$NVIM_OS" == "darwin" ]] && NVIM_OS="macos"
NVIM_ARCH="$ARCH"; [[ "$NVIM_ARCH" == "aarch64" ]] && NVIM_ARCH="arm64"
if [[ "$OS_NAME" == "linux" ]]; then
  dl_asset neovim/neovim "^nvim-linux-${NVIM_ARCH}\.appimage$" \
    "$OFFLINE_DIR/nvim/nvim-linux-${NVIM_ARCH}.appimage" || true
fi
dl_asset neovim/neovim "^nvim-${NVIM_OS}-${NVIM_ARCH}\.tar\.gz$" \
  "$OFFLINE_DIR/nvim/nvim-${NVIM_OS}-${NVIM_ARCH}.tar.gz" || true

# ---- tmux (source tarball, version resolved at download time) ----
TMUX_TAG="$(api_latest_tag tmux/tmux)"
TMUX_TAG="${TMUX_TAG#v}"
dl_asset tmux/tmux '^tmux-.*\.tar\.gz$' "$OFFLINE_DIR/tmux/tmux-${TMUX_TAG:-3.8}.tar.gz" || true

# ---- gpakosz/.tmux framework ----
if [[ ! -f "$OFFLINE_DIR/tmux/gpakosz-tmux.tar.gz" ]]; then
  fetch "https://github.com/gpakosz/.tmux/archive/refs/heads/master.tar.gz" \
    "$OFFLINE_DIR/tmux/gpakosz-tmux.tar.gz" && ok "gpakosz/.tmux saved"
fi

# ---- zimfw (installer checks offline/zsh and offline/nvim) ----
# zimfw publishes no GitHub release assets; master's zimfw.zsh is the installer.
if [[ ! -f "$OFFLINE_DIR/zsh/zimfw.zsh" ]]; then
  fetch "https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh" \
    "$OFFLINE_DIR/zsh/zimfw.zsh" && ok "zimfw saved"
fi
cp -f "$OFFLINE_DIR/zsh/zimfw.zsh" "$OFFLINE_DIR/nvim/zimfw.zsh" 2>/dev/null || true

# ---- Miniconda ----
case "$(uname -s)-$ARCH" in
  Darwin-arm64)  CONDA_FILE="Miniconda3-latest-MacOSX-arm64.sh" ;;
  Darwin-x86_64) CONDA_FILE="Miniconda3-latest-MacOSX-x86_64.sh" ;;
  Linux-x86_64)  CONDA_FILE="Miniconda3-latest-Linux-x86_64.sh" ;;
  Linux-aarch64) CONDA_FILE="Miniconda3-latest-Linux-aarch64.sh" ;;
esac
if [[ ! -f "$OFFLINE_DIR/conda/$CONDA_FILE" ]]; then
  fetch "https://repo.anaconda.com/miniconda/$CONDA_FILE" "$OFFLINE_DIR/conda/$CONDA_FILE" && ok "miniconda: $CONDA_FILE"
fi

# ---- Node.js (nvm replacement: tarball unpacked into ~/.local) ----
NODE_VER="$(curl -fsSL --connect-timeout 10 https://nodejs.org/dist/index.json 2>/dev/null |
  python3 -c 'import json,sys
try:
    print(next(r["version"] for r in json.load(sys.stdin) if r.get("lts")))
except Exception:
    print("v22.16.0")' 2>/dev/null)"
NODE_TAR="node-${NODE_VER:-v22.16.0}-${OS_NAME}-${NODE_ARCH}.tar.gz"
if [[ ! -f "$OFFLINE_DIR/node/$NODE_TAR" ]]; then
  fetch "https://nodejs.org/dist/${NODE_VER:-v22.16.0}/$NODE_TAR" "$OFFLINE_DIR/node/$NODE_TAR" && ok "node: $NODE_TAR"
fi

# ---- vcpkg ----
if [[ ! -f "$OFFLINE_DIR/nvim/vcpkg.tar.gz" ]]; then
  fetch "https://github.com/microsoft/vcpkg/archive/refs/heads/master.tar.gz" \
    "$OFFLINE_DIR/nvim/vcpkg.tar.gz" && ok "vcpkg saved"
fi

# ---- Modern CLI binaries (installed by install_tools.sh from offline/bins) ----
# Each archive is stored as <cmd>.<ext>; the installer locates the binary by
# name inside the archive. Asset names differ per project, so match the exact
# release target triple for this platform.
case "$OS_NAME-$ARCH" in
  darwin-arm64)  TRIPLE="aarch64-apple-darwin";        LG_OS="darwin"; LG_ARCH="arm64"; FZF_ARCH="arm64" ;;
  darwin-x86_64) TRIPLE="x86_64-apple-darwin";         LG_OS="darwin"; LG_ARCH="x86_64"; FZF_ARCH="amd64" ;;
  linux-arm64|linux-aarch64) TRIPLE="aarch64-unknown-linux-gnu"; LG_OS="linux"; LG_ARCH="arm64"; FZF_ARCH="arm64" ;;
  linux-x86_64)  TRIPLE="x86_64-unknown-linux-gnu";    LG_OS="linux"; LG_ARCH="x86_64"; FZF_ARCH="amd64" ;;
esac
GLOW_ARCH="$LG_ARCH"

dl_asset eza-community/eza     "^eza_${TRIPLE}\.tar\.gz$"                       "$OFFLINE_DIR/bins/eza.tar.gz"     || true
dl_asset sharkdp/bat           "^bat-v[0-9.]+-${TRIPLE}\.tar\.gz$"              "$OFFLINE_DIR/bins/bat.tar.gz"     || true
dl_asset BurntSushi/ripgrep    "^ripgrep-[0-9.]+-${TRIPLE}\.tar\.gz$"           "$OFFLINE_DIR/bins/rg.tar.gz"      || true
dl_asset sharkdp/fd            "^fd-v[0-9.]+-${TRIPLE}\.tar\.gz$"               "$OFFLINE_DIR/bins/fd.tar.gz"      || true
dl_asset junegunn/fzf          "^fzf-[0-9.]+-${LG_OS}_${FZF_ARCH}\.tar\.gz$"     "$OFFLINE_DIR/bins/fzf.tar.gz"     || true
dl_asset sxyazi/yazi           "^yazi-${TRIPLE}\.(zip|tar\.gz)$"                "$OFFLINE_DIR/bins/yazi.zip"       || true
dl_asset jesseduffield/lazygit "^lazygit_[0-9.]+_${LG_OS}_${LG_ARCH}\.tar\.gz$" "$OFFLINE_DIR/bins/lazygit.tar.gz" || true
dl_asset charmbracelet/glow    "^glow_[0-9.]+_${OS_LABEL}_${GLOW_ARCH}\.tar\.gz$" "$OFFLINE_DIR/bins/glow.tar.gz"  || true

# Some projects (e.g. eza) publish no macOS builds. When the tool is already
# installed here, package the local binary so the offline bundle stays complete.
for c in eza bat rg fzf fd yazi lazygit glow tree htop jq; do
  if ! ls "$OFFLINE_DIR/bins/$c" "$OFFLINE_DIR/bins/$c".* &>/dev/null 2>&1; then
    if command -v "$c" &>/dev/null; then
      cp -f "$(command -v "$c")" "$OFFLINE_DIR/bins/$c" 2>/dev/null &&
        chmod +x "$OFFLINE_DIR/bins/$c" &&
        ok "$c: packaged local binary (upstream has no asset for this platform)"
    fi
  fi
done

# ---- herdr (plain binary, asset name is herdr-<os>-<arch>) ----
HERDR_OS="$OS_NAME"; [[ "$HERDR_OS" == "darwin" ]] && HERDR_OS="macos"
HERDR_ARCH="$ARCH"; [[ "$HERDR_ARCH" == "x86_64" ]] || HERDR_ARCH="aarch64"
dl_asset herdrdev/herdr "^herdr-${HERDR_OS}-${HERDR_ARCH}$" "$OFFLINE_DIR/bins/herdr" || true
chmod +x "$OFFLINE_DIR/bins/herdr" 2>/dev/null || true

# ---- omp (installed by its own installer; copy the local binary) ----
if command -v omp &>/dev/null; then
  cp -f "$(command -v omp)" "$OFFLINE_DIR/bins/omp" && chmod +x "$OFFLINE_DIR/bins/omp" && ok "omp binary copied from $(command -v omp)"
else
  warn "omp not installed on this machine — add offline/bins/omp manually if you need it offline"
fi

# ---- Nerd Font (upstream ships Meslo.zip; it contains MesloLGL Nerd Font) ----
dl_asset ryanoasis/nerd-fonts '^Meslo\.zip$' "$OFFLINE_DIR/fonts/MesloLGLNerdFont.zip" || true

echo ""
echo "========================================="
echo "  ✅ Download pass finished"
echo "========================================="
echo ""
du -sh "$OFFLINE_DIR"/* 2>/dev/null || true
echo ""
echo "Missing items are reported as [WARN] above; re-run after fixing them."
echo "Then copy the whole dotfiles/ directory to the offline machine and run:"
echo "  ./install.sh --offline"
