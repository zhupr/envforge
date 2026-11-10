#!/usr/bin/env bash
# =================================================================
# dotfiles — one-click dev environment installer
#
# Usage:
#   ./install.sh              # install everything
#   ./install.sh --zsh        # only zsh config
#   ./install.sh --nvim --cpp # neovim + C++ toolchain
#   ./install.sh --offline    # install from local/offline packages
#
# Company network? Set these env vars before running:
#   export GITHUB_MIRROR=https://ghproxy.com/https://github.com
#   export HOMEBREW_API_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
#   export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
#   export APT_MIRROR=mirrors.tuna.tsinghua.edu.cn
#   export GOPROXY=https://goproxy.cn,direct
#   export PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
#   export NVM_MIRROR=https://npmmirror.com/mirrors/nvm
#   export CONDA_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/anaconda
#
# Or run: source scripts/setup_proxy.sh   (auto-detect China mirrors)
# =================================================================
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_ROOT/scripts"

# ---- colors ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }

# ---- detect platform ----
OS="$(uname -s)"
IS_CONTAINER=false
[[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] && IS_CONTAINER=true

if [[ "$IS_CONTAINER" == true ]] || [[ "${1:-}" == "--container" ]]; then
  PKG_MGR="apt"
  info "Container environment detected"
elif [[ "$OS" == "Darwin" ]]; then
  PKG_MGR="brew"
elif [[ "$OS" == "Linux" ]]; then
  if command -v apt-get &>/dev/null; then
    PKG_MGR="apt"
  elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
  elif command -v yum &>/dev/null; then
    PKG_MGR="yum"
  else
    PKG_MGR="unknown"
    warn "Unknown package manager, some features may not work"
  fi
else
  err "Unsupported OS: $OS"; exit 1
fi

info "Platform: $OS | Package manager: $PKG_MGR"

# ---- parse flags ----
DO_ZSH=false; DO_NVIM=false; DO_TMUX=false; DO_CPP=false
DO_PYTHON=false; DO_GO=false; DO_TOOLS=false; DO_RUST=false; DO_OFFLINE=false
DO_HERDR=false; DO_OMP=false
DO_INTERACTIVE=false

if [[ $# -eq 0 ]]; then
  DO_ZSH=true; DO_NVIM=true; DO_TMUX=true; DO_CPP=true
  DO_PYTHON=true; DO_GO=true; DO_TOOLS=true; DO_RUST=true; DO_HERDR=true; DO_OMP=true
else
  for arg in "$@"; do
    case "$arg" in
      --all)       DO_ZSH=true; DO_NVIM=true; DO_TMUX=true; DO_CPP=true
                   DO_PYTHON=true; DO_GO=true; DO_TOOLS=true; DO_RUST=true; DO_HERDR=true; DO_OMP=true ;;
      --zsh)       DO_ZSH=true ;;
      --nvim)      DO_NVIM=true ;;
      --tmux)      DO_TMUX=true ;;
      --cpp)       DO_CPP=true ;;
      --python)    DO_PYTHON=true ;;
      --go)        DO_GO=true ;;
      --tools)     DO_TOOLS=true ;;
      --rust)      DO_RUST=true ;;
      --herdr)     DO_HERDR=true ;;
      --omp)       DO_OMP=true ;;
      --interactive|-i) DO_INTERACTIVE=true ;;
      --offline)   DO_OFFLINE=true ;;
      --container) ;;  # already handled above
      --help|-h)
        echo "Usage: ./install.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --all          Install everything (default)"
        echo "  --zsh          Zsh + zimfw + powerlevel10k"
        echo "  --nvim         Neovim + LazyVim config"
        echo "  --tmux         tmux + gpakosz framework"
        echo "  --cpp          C++ toolchain (cmake, llvm, clangd, vcpkg)"
        echo "  --python       Python (miniconda + pyright + ruff)"
        echo "  --go           Go toolchain"
        echo "  --rust         Rust toolchain (rustup + rust-analyzer)"
        echo "  --tools        CLI tools (eza, bat, ripgrep, fzf, fd, yazi, lazygit)"
        echo "  --herdr        Herdr terminal multiplexer (config + completion)"
        echo "  --omp          omp coding agent (config from ~/.omp/agent)"
        echo "  --interactive  Interactive component picker"
        echo "  --offline      Install from local/offline packages"
        echo "  --container    Install inside container"
        echo "  -h, --help     Show this help"
        exit 0
        ;;
      *)           warn "Unknown flag: $arg" ;;
    esac
  done
fi

# ---- helper: symlink with backup ----
link_file() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local bak="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing $dst -> $bak"
    mv "$dst" "$bak"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  ok "$dst -> $src"
}

# ---- helper: download with mirror support ----
download() {
  local url="$1" output="$2"
  # Apply GitHub mirror if set
  if [[ -n "${GITHUB_MIRROR:-}" ]]; then
    url="${url/https:\/\/github.com/$GITHUB_MIRROR}"
  fi
  if command -v curl &>/dev/null; then
    curl -fsSL --connect-timeout 10 --max-time 120 "$url" -o "$output"
  elif command -v wget &>/dev/null; then
    wget -nv --timeout=10 -O "$output" "$url"
  else
    err "Neither curl nor wget found. Install one first."
    return 1
  fi
}

# export for sub-scripts
export -f link_file info ok warn err download
export DOTFILES_ROOT SCRIPTS_DIR PKG_MGR OS IS_CONTAINER DO_OFFLINE
source "$SCRIPTS_DIR/offline.sh"
[[ "$DO_INTERACTIVE" == true ]] && source "$SCRIPTS_DIR/interactive.sh"

# ---- run install modules ----
echo ""
echo "========================================="
echo "  🚀 dotfiles installer"
echo "========================================="
echo ""

[[ "$DO_TOOLS" == true ]]  && source "$SCRIPTS_DIR/install_tools.sh"
[[ "$DO_ZSH" == true ]]    && source "$SCRIPTS_DIR/install_zsh.sh"
[[ "$DO_NVIM" == true ]]   && source "$SCRIPTS_DIR/install_nvim.sh"
[[ "$DO_TMUX" == true ]]   && source "$SCRIPTS_DIR/install_tmux.sh"
[[ "$DO_CPP" == true ]]    && source "$SCRIPTS_DIR/install_cpp.sh"
[[ "$DO_PYTHON" == true ]] && source "$SCRIPTS_DIR/install_python.sh"
[[ "$DO_GO" == true ]]     && source "$SCRIPTS_DIR/install_go.sh"
[[ "$DO_RUST" == true ]]   && source "$SCRIPTS_DIR/install_rust.sh"
[[ "$DO_HERDR" == true ]] && source "$SCRIPTS_DIR/install_herdr.sh"
[[ "$DO_OMP" == true ]]   && source "$SCRIPTS_DIR/install_omp.sh"

echo ""
echo "========================================="
echo "  ✅ Installation complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Run 'p10k configure' to set up your prompt"
echo "  3. Open nvim — plugins auto-install on first launch"
echo ""
echo "Company network tip:"
echo "  source scripts/setup_proxy.sh  # auto-detect China mirrors"
echo ""
