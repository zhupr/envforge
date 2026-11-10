# shellcheck shell=bash
# =================================================================
# Shared offline-install helpers. Sourced by install.sh after it loads
# info/ok/warn/err from its own helpers.
#
# Contract: every install_*.sh must check ${DO_OFFLINE:-false} before any
# network access. Functions return 0 = handled, 1 = caller falls back to
# online path. download_offline.sh mirrors the filenames expected here.
# =================================================================

OFFLINE_DIR="${DOTFILES_ROOT:-.}/offline"

# _offline_find <subdir> <glob> -> prints first match or empty
_offline_find() {
  local dir="$1" pat="$2" f
  for f in "$OFFLINE_DIR/$dir"/$pat; do
    [[ -e "$f" ]] && { echo "$f"; return 0; }
  done
  return 1
}

# _offline_or_warn <label> -> true if DO_OFFLINE is set; warns + false otherwise
_offline_enabled() [[ "${DO_OFFLINE:-false}" == true ]]

# _offline_skip_warn <label> <note> -> warn and return 1 when package missing
_offline_skip_warn() {
  local label="$1" note="$2"
  warn "$label: no offline package found in $OFFLINE_DIR ($note). Skipping (offline mode)."
  return 1
}

# _offline_check <label> <subdir> <glob> -> echoes path or 1 (with warn)
_offline_check() {
  local label="$1" sub="$2" pat="$3" got
  got="$(_offline_find "$sub" "$pat")" || return 1
  ok "$label: using $got"
  echo "$got"
}

# ---- archive unpackers ------------------------------------------------

# unpack_tar <archive> <dest>  tar -xzf into dest (created)
unpack_tar() {
  local archive="$1" dest="$2"
  mkdir -p "$dest"
  tar -xzf "$archive" -C "$dest"
}

# copy_tree <src> <dest>  rsync/cp -R with existing dirs merged
copy_tree() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  cp -R "$src"/. "$dest"/
}
