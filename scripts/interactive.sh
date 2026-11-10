# shellcheck shell=bash
# Interactive component picker. Sourced by install.sh when DO_INTERACTIVE=true.
# Prefers whiptail > gum > fzf; falls back to numbered prompts.
# Sets DO_* flags used by install.sh dispatch.

info "🧭 Interactive installer — select components (space to toggle, Enter to confirm)"

_has() { command -v "$1" &>/dev/null; }

_pick_with_whiptail() {
  local out
  out=$(whiptail --title "dotfiles installer" --checklist "Select components:" 20 70 12 \
    zsh "Zsh + zimfw + p10k" ON \
    nvim "Neovim + LazyVim + Node" ON \
    tmux "tmux + gpakosz" ON \
    cpp "C++ toolchain + vcpkg" ON \
    python "Python + miniconda" ON \
    go "Go toolchain" ON \
    rust "Rust toolchain" ON \
    tools "CLI tools + glow + fonts" ON \
    herdr "Herdr multiplexer" ON \
    omp "omp agent config" ON \
    3>&1 1>&2 2>&3) || return 1
  echo "$out"
}

_pick_with_gum() {
  gum choose --no-limit --selected all \
    "zsh — Zsh + zimfw + p10k" \
    "nvim — Neovim + LazyVim + Node" \
    "tmux — tmux + gpakosz" \
    "cpp — C++ toolchain + vcpkg" \
    "python — Python + miniconda" \
    "go — Go toolchain" \
    "rust — Rust toolchain" \
    "tools — CLI tools + glow + fonts" \
    "herdr — Herdr multiplexer" \
    "omp — omp agent config"
}

_apply_selection() {
  DO_ZSH=false; DO_NVIM=false; DO_TMUX=false; DO_CPP=false
  DO_PYTHON=false; DO_GO=false; DO_TOOLS=false; DO_RUST=false; DO_HERDR=false; DO_OMP=false
  local sel="$1"
  for tok in zsh nvim tmux cpp python go rust tools herdr omp; do
    if grep -q "$tok" <<<"$sel"; then
      case "$tok" in
        zsh) DO_ZSH=true ;; nvim) DO_NVIM=true ;; tmux) DO_TMUX=true ;; cpp) DO_CPP=true ;;
        python) DO_PYTHON=true ;; go) DO_GO=true ;; rust) DO_RUST=true ;; tools) DO_TOOLS=true ;;
        herdr) DO_HERDR=true ;; omp) DO_OMP=true ;;
      esac
    fi
  done
  if [[ "$DO_ZSH$DO_NVIM$DO_TMUX$DO_CPP$DO_PYTHON$DO_GO$DO_TOOLS$DO_RUST$DO_HERDR$DO_OMP" != *"true"* ]]; then
    warn "Nothing selected — defaulting to all."
    DO_ZSH=true; DO_NVIM=true; DO_TMUX=true; DO_CPP=true
    DO_PYTHON=true; DO_GO=true; DO_TOOLS=true; DO_RUST=true; DO_HERDR=true; DO_OMP=true
  fi
}

if _has whiptail; then
  _apply_selection "$(_pick_with_whiptail || echo '')"
elif _has gum; then
  _apply_selection "$(_pick_with_gum || echo '')"
elif _has fzf; then
  SEL=$(printf '%s\n' zsh nvim tmux cpp python go rust tools herdr omp | fzf --multi --reverse --header="Select components (Tab to toggle)" || true)
  _apply_selection "$SEL"
else
  warn "No interactive picker found (whiptail/gum/fzf). Installing all components."
  DO_ZSH=true; DO_NVIM=true; DO_TMUX=true; DO_CPP=true
  DO_PYTHON=true; DO_GO=true; DO_TOOLS=true; DO_RUST=true; DO_HERDR=true; DO_OMP=true
fi

# Also ask about offline mode
if [[ -t 0 ]]; then
  if _has whiptail; then
    whiptail --yesno "Install from offline packages (offline/ dir)?" 10 60 3>&2 2>&1 1>&3 && DO_OFFLINE=true || true
  else
    printf 'Offline mode? (y/N) '
    read -r ans; [[ "${ans:-}" =~ ^[Yy]$ ]] && DO_OFFLINE=true
  fi
fi
ok "Selected: ZSH=$DO_ZSH NVIM=$DO_NVIM TMUX=$DO_TMUX CPP=$DO_CPP PY=$DO_PYTHON GO=$DO_GO RUST=$DO_RUST TOOLS=$DO_TOOLS HERDR=$DO_HERDR OMP=$DO_OMP OFFLINE=$DO_OFFLINE"
