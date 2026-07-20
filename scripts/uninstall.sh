#!/usr/bin/env bash
# =================================================================
# Remove symlinks created by the installer
# Does NOT remove installed packages
# =================================================================
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }

remove_link() {
  local target="$1"
  if [[ -L "$target" ]]; then
    rm "$target"
    info "Removed symlink: $target"
  else
    warn "Not a symlink, skipping: $target"
  fi
}

echo ""
echo "  🗑️  dotfiles uninstaller"
echo ""

remove_link "$HOME/.zshrc"
remove_link "$HOME/.zimrc"
remove_link "$HOME/.p10k.zsh"
remove_link "$HOME/.ripgreprc"
remove_link "$HOME/.config/nvim"
remove_link "$HOME/.tmux.conf"
remove_link "$HOME/.tmux.conf.local"
remove_link "$HOME/.config/yazi/yazi.toml"
remove_link "$HOME/.config/yazi/keymap.toml"

echo ""
info "Done. Symlinks removed."
info "Installed packages were NOT removed."
echo ""
for bak in "$HOME"/.zshrc.bak.* "$HOME"/.config/nvim.bak.*; do
  if [[ -e "$bak" ]]; then
    original="${bak%%.bak.*}"
    warn "Backup found: $bak -> restore with: mv '$bak' '$original'"
  fi
done
