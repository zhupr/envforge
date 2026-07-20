# =================================================================
# Go toolchain
# =================================================================
info "🐹 Setting up Go..."

if ! command -v go &>/dev/null; then
  GO_VERSION="1.24.4"
  case "$PKG_MGR" in
    brew) brew install go ;;
    apt|dnf|yum)
      ARCH="$(uname -m)"
      case "$ARCH" in
        x86_64) GO_ARCH="amd64" ;;
        aarch64|arm64) GO_ARCH="arm64" ;;
        *) err "Unsupported arch: $ARCH"; return 1 ;;
      esac
      GO_TAR="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
      download "https://go.dev/dl/$GO_TAR" "/tmp/$GO_TAR"
      sudo rm -rf /usr/local/go
      sudo tar -C /usr/local -xzf "/tmp/$GO_TAR"
      rm -f "/tmp/$GO_TAR"
      export PATH="/usr/local/go/bin:$PATH"
      ;;
  esac
  ok "Go installed"
else
  ok "Go already installed ($(go version 2>/dev/null))"
fi

# Configure Go proxy for China
GOPROXY="${GOPROXY:-}"
if [[ -z "$GOPROXY" ]]; then
  export GOPROXY="https://goproxy.io,direct"
fi

# Install Go tools for nvim
info "Installing Go development tools..."
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$GOPATH/bin:$PATH"

go install golang.org/x/tools/gopls@latest 2>/dev/null || warn "gopls install failed (network?)"
go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null || warn "delve install failed"
go install honnef.co/go/tools/cmd/staticcheck@latest 2>/dev/null || warn "staticcheck install failed"

ok "Go toolchain ready"
