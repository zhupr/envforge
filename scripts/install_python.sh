# =================================================================
# Python: miniconda + development tools (pyright, ruff)
# =================================================================
info "🐍 Setting up Python environment..."

CONDA_DIR="$HOME/miniconda3"
if [[ "${DO_OFFLINE:-false}" == true ]]; then
  CONDA_SH="$(ls "$OFFLINE_DIR/conda"/Miniconda3-*.sh 2>/dev/null | head -n1)"
  if [[ -n "$CONDA_SH" ]]; then
    bash "$CONDA_SH" -b -p "$CONDA_DIR" && ok "Miniconda offline installed"
  else
    warn "Miniconda installer missing in $OFFLINE_DIR/conda/ — skipping Python (offline mode)."
  fi
  # Skip online install below
  DO_PYTHON_OFFLINE_DONE=true
fi
if [[ "${DO_PYTHON_OFFLINE_DONE:-false}" == true ]]; then
  : # offline already handled
elif [[ ! -d "$CONDA_DIR" ]]; then
  info "Installing miniconda..."
  ARCH="$(uname -m)"
  CONDA_MIRROR="${CONDA_MIRROR:-https://repo.anaconda.com/miniconda}"
  case "$(uname -s)-$ARCH" in
    Darwin-arm64)  CONDA_URL="$CONDA_MIRROR/Miniconda3-latest-MacOSX-arm64.sh" ;;
    Darwin-x86_64) CONDA_URL="$CONDA_MIRROR/Miniconda3-latest-MacOSX-x86_64.sh" ;;
    Linux-x86_64)  CONDA_URL="$CONDA_MIRROR/Miniconda3-latest-Linux-x86_64.sh" ;;
    Linux-aarch64) CONDA_URL="$CONDA_MIRROR/Miniconda3-latest-Linux-aarch64.sh" ;;
    *) err "Unsupported platform for miniconda"; return 1 ;;
  esac
  download "$CONDA_URL" "/tmp/miniconda.sh"
  bash /tmp/miniconda.sh -b -p "$CONDA_DIR"
  rm -f /tmp/miniconda.sh
  ok "Miniconda installed at $CONDA_DIR"
else
  ok "Miniconda already installed"
fi

# Configure conda mirror if in China
if [[ -n "${CONDA_MIRROR:-}" ]] && [[ "$CONDA_MIRROR" != "https://repo.anaconda.com/miniconda" ]]; then
  "$CONDA_DIR/bin/conda" config --set show_channel_urls true 2>/dev/null || true
  "$CONDA_DIR/bin/conda" config --add channels "${CONDA_MIRROR}/pkgs/main" 2>/dev/null || true
  "$CONDA_DIR/bin/conda" config --add channels "${CONDA_MIRROR}/pkgs/r" 2>/dev/null || true
fi

# Configure pip mirror
PIP_INDEX_URL="${PIP_INDEX_URL:-}"
if [[ -n "$PIP_INDEX_URL" ]]; then
  mkdir -p "$HOME/.config/pip"
  cat > "$HOME/.config/pip/pip.conf" << PIPCONF
[global]
index-url = $PIP_INDEX_URL
trusted-host = $(echo "$PIP_INDEX_URL" | sed 's|https://||;s|/.*||')
PIPCONF
  ok "pip mirror configured: $PIP_INDEX_URL"
fi

# Install Python dev tools
info "Installing Python dev tools..."
if [[ "${DO_OFFLINE:-false}" != true ]]; then
  "$CONDA_DIR/bin/pip" install --upgrade pip 2>/dev/null || true
  "$CONDA_DIR/bin/pip" install ruff pyright 2>/dev/null || true
fi

ok "Python environment ready"
