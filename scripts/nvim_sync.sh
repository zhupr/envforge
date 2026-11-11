#!/usr/bin/env bash
# =================================================================
# Headless Neovim bootstrap that does not abort Mason installs.
#
# `nvim --headless "+Lazy! sync" +qa` exits as soon as Lazy is done, which kills
# Mason's asynchronous installs ("Neovim is exiting while packages are still
# installing"). This script syncs plugins and then blocks until every Mason
# package has finished, with a timeout.
#
#   ./scripts/nvim_sync.sh              # default 900s budget
#   NVIM_SYNC_TIMEOUT=1800 ./scripts/nvim_sync.sh
# =================================================================
set -uo pipefail

TIMEOUT="${NVIM_SYNC_TIMEOUT:-900}"

if ! command -v nvim >/dev/null 2>&1; then
  echo "[ERROR] nvim not found in PATH" >&2
  exit 1
fi

echo "[INFO]  Lazy sync + wait for Mason installs (timeout ${TIMEOUT}s)"
nvim --headless \
  "+Lazy! sync" \
  "+lua local ok, reg = pcall(require, 'mason-registry'); if not ok then return end; local function busy() for _, p in ipairs(reg.get_all_packages()) do if p:is_installing() then return true end end return false end; local done = vim.wait(tonumber('${TIMEOUT}') * 1000, function() return not busy() end, 1000); if not done then vim.notify('Mason installs still running after ' .. '${TIMEOUT}' .. 's', vim.log.levels.WARN) end" \
  "+qa"
status=$?

if [ "$status" -ne 0 ]; then
  echo "[WARN]  nvim exited with status $status" >&2
fi
echo "[OK]    Neovim plugins/Mason up to date"
