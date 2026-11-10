#!/usr/bin/env bash
# =================================================================
# Herdr terminal multiplexer (herdr.dev) — binary + config + completion
# Config: ~/.config/herdr/config.toml  (sub-commands: herdr server/stop)
# =================================================================
info "🛰️  Setting up Herdr..."

if command -v herdr &>/dev/null; then
  ok "herdr already installed ($(herdr --version 2>/dev/null))"
else
  if [[ "${DO_OFFLINE:-false}" == true ]]; then
    HERDR_BIN="$(ls "$OFFLINE_DIR/bins"/herdr* "$OFFLINE_DIR/herdr"/herdr* 2>/dev/null | head -n1)"
    if [[ -n "$HERDR_BIN" ]]; then
      mkdir -p "$HOME/.local/bin" && cp "$HERDR_BIN" "$HOME/.local/bin/herdr" && chmod +x "$HOME/.local/bin/herdr"
      ok "herdr offline installed from $HERDR_BIN"
    else
      warn "herdr binary missing offline (add offline/bins/herdr* or offline/herdr/*) — skipping herdr install."
    fi
  elif [[ "$PKG_MGR" == "brew" ]]; then
    brew install herdr
  else
    download "https://herdr.dev/install.sh" "/tmp/herdr-install.sh" && sh /tmp/herdr-install.sh || \
      warn "herdr install failed — see https://herdr.dev/install.sh"
  fi
fi

mkdir -p "$HOME/.config/herdr"
link_file "$DOTFILES_ROOT/config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# zsh completion
if command -v herdr &>/dev/null; then
  mkdir -p ~/.zfunc
  herdr completion zsh > ~/.zfunc/_herdr 2>/dev/null && ok "herdr zsh completion -> ~/.zfunc/_herdr"
fi

ok "Herdr ready — run 'herdr' to launch; 'herdr server stop' to stop"
