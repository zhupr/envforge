#!/usr/bin/env bash
# =================================================================
# omp coding agent (omp.sh, v18) — install binary + base config
# Base config synced from local (~/.omp/agent/config.yml created by
# `omp` first run; API keys are NOT stored in it — auth lives in
# ~/.omp/agent/agent.db and env vars such as PI_PROXY_*).
# =================================================================
info "🤖 Setting up omp..."

if command -v omp &>/dev/null; then
  ok "omp already installed ($(omp --version 2>/dev/null | head -n1))"
else
  if [[ "${DO_OFFLINE:-false}" == true ]]; then
    OMP_BIN="$(ls "$OFFLINE_DIR/bins"/omp* "$OFFLINE_DIR/omp"/omp* 2>/dev/null | head -n1 || true)"
    if [[ -n "$OMP_BIN" ]]; then
      mkdir -p "$HOME/.local/bin" && cp "$OMP_BIN" "$HOME/.local/bin/omp" && chmod +x "$HOME/.local/bin/omp"
      ok "omp offline installed from $OMP_BIN"
    else
      warn "omp binary missing offline (add offline/bins/omp*) — run online once to install."
    fi
  elif [[ "$PKG_MGR" == "brew" ]]; then
    brew install omp 2>/dev/null || download "https://omp.sh/install" "/tmp/omp-install.sh" && sh /tmp/omp-install.sh || \
      warn "omp install failed — see https://omp.sh/install"
  else
    download "https://omp.sh/install" "/tmp/omp-install.sh" && sh /tmp/omp-install.sh || \
      warn "omp install failed — see https://omp.sh/install"
  fi
fi

# Base config: synced from local ~/.omp/agent/config.yml (no secrets inside).
# Do NOT overwrite an existing non-symlink config without backup — link_file
# already backs up to .bak.<timestamp>.
mkdir -p "$HOME/.omp/agent"
link_file "$DOTFILES_ROOT/config/omp/agent/config.yml" "$HOME/.omp/agent/config.yml"

ok "omp ready — run 'omp' to start; configure providers with /login"
