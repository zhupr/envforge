#!/usr/bin/env bash
# =================================================================
# Auto-detect and configure China mirrors for dev tools
# Usage: source scripts/setup_proxy.sh
#
# Detects if you're in China (by checking connectivity to github.com)
# and sets mirror/proxy environment variables accordingly.
# =================================================================

check_china() {
  # Quick connectivity check
  if curl -s --connect-timeout 3 -o /dev/null https://www.baidu.com 2>/dev/null; then
    return 0
  fi
  return 1
}

echo "🌐 Detecting network environment..."

if check_china; then
  echo "  → China mainland detected, configuring mirrors..."

  # GitHub mirror (for git clone and raw file downloads)
  export GITHUB_MIRROR="https://ghfast.top/https://github.com"

  # Homebrew (macOS)
  export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
  export HOMEBREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew"
  export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"

  # APT mirror (Ubuntu/Debian)
  export APT_MIRROR="mirrors.tuna.tsinghua.edu.cn"

  # Go proxy
  export GOPROXY="https://goproxy.cn,direct"
  export GOSUMDB="sum.golang.google.cn"
  export GOPRIVATE=""

  # pip / PyPI
  export PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
  export PIP_TRUSTED_HOST="pypi.tuna.tsinghua.edu.cn"

  # conda
  export CONDA_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/anaconda"

  # npm / node
  export NVM_NODEJS_ORG_MIRROR="https://npmmirror.com/mirrors/node"
  export NVM_MIRROR="https://npmmirror.com/mirrors/nvm"
  export NPM_CONFIG_REGISTRY="https://registry.npmmirror.com"

  # Rust / cargo
  export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
  export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"
  export CARGO_REGISTRIES_CRATES_IO_PROTOCOL="sparse"
  export CARGO_REGISTRIES_CRATES_IO_INDEX="https://mirrors.ustc.edu.cn/crates.io-index/"

  # Neovim lazy.nvim (override GitHub URLs in lazy.lua)
  export LAZY_GITHUB_MIRROR="https://ghfast.top/https://github.com"

  echo "  ✅ Mirrors configured. Run install.sh now."
  echo ""
  echo "  Configured mirrors:"
  echo "    GitHub:   $GITHUB_MIRROR"
  echo "    Homebrew: $HOMEBREW_BOTTLE_DOMAIN"
  echo "    Go:       $GOPROXY"
  echo "    pip:      $PIP_INDEX_URL"
  echo "    npm:      $NPM_CONFIG_REGISTRY"
  echo "    Rust:     $RUSTUP_DIST_SERVER"
else
  echo "  → Direct internet access detected, no mirror needed."
  # Still set Go proxy as it's faster everywhere
  export GOPROXY="https://goproxy.io,direct"
  export CARGO_REGISTRIES_CRATES_IO_PROTOCOL="sparse"
fi
