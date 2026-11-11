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

# _gh_api <path>  -> GET api.github.com, authenticated when a token is available
_gh_api() {
  local path="$1" token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  local -a auth=()
  [[ -n "$token" ]] && auth=(-H "Authorization: Bearer $token")
  curl -fsSL --connect-timeout 10 --max-time 30 "${auth[@]}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com$path" 2>/dev/null
}

# api_asset_url <owner/repo> <regex>
# Prints the browser_download_url of the first asset in the latest release whose
# file name matches <regex>. Empty output when offline, rate-limited or absent.
# Set GITHUB_TOKEN (or GH_TOKEN) to lift the anonymous 60 req/h limit.
api_asset_url() {
  local repo="$1" pat="$2" json=""
  json="$(_gh_api "/repos/$repo/releases/latest")" || return 0
  printf '%s' "$json" | python3 -c '
import json, re, sys
pat = re.compile(sys.argv[1])
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for a in data.get("assets", []):
    if pat.search(a.get("name", "")):
        print(a["browser_download_url"])
        break
' "$pat" 2>/dev/null
}

# api_latest_tag <owner/repo> -> prints tag_name (empty on failure)
api_latest_tag() {
  local repo="$1"
  _gh_api "/repos/$repo/releases/latest" |
    python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("tag_name",""))
except Exception:
    pass' 2>/dev/null
}

# install_offline_bin <cmd> <destdir>
# Looks for $OFFLINE_DIR/bins/<cmd>*, accepts a plain executable or an archive
# (.tar.gz/.tgz/.zip), extracts it and installs <cmd> into <destdir>.
# Returns 0 when <destdir>/<cmd> ends up executable, 1 otherwise.
install_offline_bin() {
  local cmd="$1" dest="$2" art tmp found
  mkdir -p "$dest"
  art="$(_offline_find bins "$cmd*")" || return 1
  [[ -n "$art" && -f "$art" ]] || return 1

  case "$art" in
    *.tar.gz|*.tgz)
      tmp="$(mktemp -d)"
      tar -xzf "$art" -C "$tmp" 2>/dev/null || { rm -rf "$tmp"; return 1; }
      found="$(find "$tmp" -type f -name "$cmd" -perm -u+x 2>/dev/null | head -n1)"
      [[ -z "$found" ]] && found="$(find "$tmp" -type f -name "$cmd" 2>/dev/null | head -n1)"
      if [[ -n "$found" ]]; then
        cp "$found" "$dest/$cmd" && chmod +x "$dest/$cmd"
      fi
      rm -rf "$tmp"
      ;;
    *.zip)
      tmp="$(mktemp -d)"
      if command -v unzip &>/dev/null; then
        unzip -qo "$art" -d "$tmp" 2>/dev/null || { rm -rf "$tmp"; return 1; }
        found="$(find "$tmp" -type f -name "$cmd" 2>/dev/null | head -n1)"
        [[ -n "$found" ]] && cp "$found" "$dest/$cmd" && chmod +x "$dest/$cmd"
      fi
      rm -rf "$tmp"
      ;;
    *)
      cp "$art" "$dest/$cmd" 2>/dev/null && chmod +x "$dest/$cmd"
      ;;
  esac

  [[ -x "$dest/$cmd" ]] || return 1
  echo "$dest/$cmd"
  return 0
}
