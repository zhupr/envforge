# envforge

**English** · [简体中文](README.zh-CN.md)

One-command developer environment for **macOS**, **Linux** and **Docker** — covering
Zsh, Neovim (LazyVim), tmux, Herdr, omp, C++/Python/Go/Rust toolchains and a set of
modern CLI tools. Works online, behind a corporate mirror, or fully offline.

```bash
git clone https://github.com/<you>/envforge.git ~/code/envforge
cd ~/code/envforge
./install.sh                # everything
./install.sh --zsh --nvim   # or just what you need
./install.sh --interactive  # pick components from a menu
```

## What you get

| Component | macOS | Linux | Config |
|---|---|---|---|
| **Zsh** | zsh + zimfw + powerlevel10k | same | `.zshrc`, `.zimrc` |
| **Neovim** | neovim | AppImage or tarball | LazyVim + TokyoNight, `blink.cmp` |
| **tmux** | tmux + gpakosz | same | `tmux.conf.local` |
| **Herdr** | brew / installer | installer | `~/.config/herdr/config.toml` |
| **omp** | installer | installer | `~/.omp/agent/config.yml` |
| **C++** | cmake + llvm | cmake + clang | clangd, clang-format, vcpkg |
| **Python** | miniconda | miniconda | ruff, pyright |
| **Go** | go | tarball | gopls, delve, staticcheck |
| **Rust** | rustup | rustup | rust-analyzer |
| **Node.js** | nvm | nvm / tarball | LTS |
| **CLI tools** | eza, bat, ripgrep, fzf, fd, yazi, lazygit, tree, htop, jq, wget, glow | same | aliases in `.zshrc` |
| **Nerd Font** | Meslo LG L | Meslo LG L | terminal font setting |

Enabled LazyVim extras include `editor.fzf`, `editor.harpoon2`, `lang.markdown`,
`lang.python`, `lang.rust`, `lang.typescript`, `lang.yaml`, `linting.eslint`,
`formatting.prettier`, `util.project` and more (see `config/nvim/lazyvim.json`).

## Options

```bash
./install.sh --all          # everything (default with no flags)
./install.sh --zsh          # Zsh + zimfw + powerlevel10k
./install.sh --nvim         # Neovim + LazyVim config
./install.sh --tmux         # tmux + gpakosz framework
./install.sh --cpp          # C++ toolchain
./install.sh --python       # Python + miniconda
./install.sh --go           # Go
./install.sh --rust         # Rust
./install.sh --tools        # CLI tools + Nerd Font + glow
./install.sh --herdr        # Herdr multiplexer
./install.sh --omp          # omp agent config
./install.sh --interactive  # whiptail / gum / fzf picker
./install.sh --offline      # use packages from offline/ (implies --all)
./install.sh --container    # force container (apt) mode
```

Exit codes are meaningful: a failed required component stops the run; optional
extras (Mason packages, gpakosz framework, vcpkg bootstrap, Go tools) degrade to a
warning so the rest of the install still completes.

## Project layout

```
envforge/
├── install.sh                     # entry point
├── Makefile                       # make install / update / nvim-sync / container
├── config/
│   ├── zsh/                       # .zshrc, .zimrc, .ripgreprc
│   ├── nvim/                       # LazyVim config, symlinked to ~/.config/nvim
│   ├── tmux/tmux.conf.local
│   ├── yazi/
│   ├── herdr/config.toml
│   └── omp/agent/config.yml       # base omp config (no credentials)
├── scripts/
│   ├── install_*.sh               # one module per component
│   ├── offline.sh                 # shared offline helpers
│   ├── download_offline.sh        # build the offline bundle
│   ├── interactive.sh             # component picker
│   ├── nvim_sync.sh               # headless Lazy sync + wait for Mason
│   ├── setup_proxy.sh             # China mirrors
│   └── uninstall.sh
├── containers/                    # Dockerfile, docker-compose.yml, devcontainer
└── offline/                       # downloaded packages (gitignored)
```

## Corporate networks and mirrors

```bash
source scripts/setup_proxy.sh     # detects China and exports mirrors
./install.sh
```

| Tool | Mirror |
|---|---|
| GitHub | `GITHUB_MIRROR` (e.g. `https://ghfast.top/https://github.com`) |
| Homebrew | `HOMEBREW_API_DOMAIN`, `HOMEBREW_BOTTLE_DOMAIN` |
| APT | `APT_MIRROR` |
| Go | `GOPROXY` |
| pip | `PIP_INDEX_URL` |
| npm / nvm | `NVM_NODEJS_ORG_MIRROR` |
| Conda | `CONDA_MIRROR` |
| Rust | `RUSTUP_DIST_SERVER`, `RUSTUP_UPDATE_ROOT` |

Useful environment switches for the installer itself:

| Variable | Effect |
|---|---|
| `SKIP_GO_TOOLS=true` | skip `gopls`/`delve`/`staticcheck` builds (slow) |
| `MASON_RESTRICTED=1` | Neovim: use the `mason.providers.client` provider only |
| `DOTFILES_RESTRICTED_NETWORK=1` | same as above |
| `HTTPS_PROXY` | honoured by curl, git and the offline downloader |

## Offline installation

1. On a machine with network (python3 required, `GITHUB_TOKEN` recommended to avoid
   the 60 req/h API limit):

   ```bash
   export GITHUB_TOKEN=...          # optional but recommended
   ./scripts/download_offline.sh
   ```

   Asset names are resolved through the GitHub API for the *latest* release, so
   nothing is pinned to a stale `/latest/download/<name>` path.

2. Copy the whole `envforge/` directory to the target machine.

3. Install:

   ```bash
   ./install.sh --offline            # implies --all
   ./install.sh --offline --tools    # or a subset
   ```

Bundle contents (`offline/`):

| Path | Contents |
|---|---|
| `go/` | Go tarball |
| `rust/rust-toolchain.tar.gz` | full `~/.rustup` + `~/.cargo` snapshot (installs without network) |
| `nvim/` | Neovim AppImage (Linux) or tarball (Linux/macOS), zimfw, vcpkg |
| `tmux/` | tmux source tarball, gpakosz framework |
| `conda/`, `node/` | Miniconda and Node.js tarballs |
| `bins/` | herdr, omp plus archives for eza/bat/rg/fd/fzf/yazi/lazygit/glow |
| `fonts/` | Meslo Nerd Font zip |

**Known limits** — the offline bundle cannot carry these, by design:

* Neovim *plugins*, tree-sitter parsers and Mason packages still need network on the
  first `nvim` start. Run `./scripts/nvim_sync.sh` once on a networked machine and
  copy `~/.local/share/nvim` together with `~/.local/share/nvim/mason`.
* Rust is provisioned from the bundled toolchain snapshot; `rustup update` needs
  network.
* System packages (clang/cmake/zsh/tmux) come from the OS package manager. Where a
  prebuilt copy is unavailable the installer warns and then still tries
  `brew`/`apt`, so a warm cache or reachable mirror is used instead of being blocked.

## Docker

```bash
docker compose -f containers/docker-compose.yml up -d --build
docker compose -f containers/docker-compose.yml exec dev zsh
```

Build arguments:

| Argument | Default | Purpose |
|---|---|---|
| `BASE_IMAGE` | `ubuntu:26.04` | base image |
| `OFFLINE` | `false` | run `install.sh --all --offline` |
| `SKIP_GO_TOOLS` | `true` | skip Go tool builds in the image |

`./install.sh --container` only switches to apt mode; it installs nothing by itself,
so the image runs `--all` explicitly.

## Neovim notes

**Mason behind a restricted network.** With the default providers an unreachable
`api.mason-registry.dev` makes `:MasonUpdate` hang. Use the client-only provider:

```bash
MASON_RESTRICTED=1 nvim
```

**Headless bootstrap.** `nvim --headless "+Lazy! sync" +qa` exits before Mason's
asynchronous installs finish. Use the wrapper, which waits:

```bash
./scripts/nvim_sync.sh              # or: make nvim-sync
NVIM_SYNC_TIMEOUT=1800 ./scripts/nvim_sync.sh
```

**Clipboard over SSH.** When `SSH_TTY`/`SSH_CONNECTION` is set, Neovim enables
OSC 52 (`vim.g.clipboard = "osc52"`) so `y` reaches the local clipboard even when the
remote host has no clipboard provider. Requirements:

* Terminal support — iTerm2 (enable *Applications in terminal may access clipboard*),
  WezTerm, Kitty, Ghostty. Apple Terminal does not support OSC 52.
* tmux — `set -g allow-passthrough on` (already in `tmux.conf.local`).
* Fallback: hold Shift (Terminal.app) or Option (iTerm2) while dragging, or run
  `:set mouse=` and use the terminal's native selection.

**Themes.** TokyoNight is the default; Catppuccin and Gruvbox are preconfigured in
`config/nvim/lua/plugins/colorscheme.lua` — uncomment the matching
`{ "LazyVim/LazyVim", opts = { colorscheme = "..." } }` line.

## Machine-specific settings

| File | Purpose |
|---|---|
| `~/.zshrc.local` | sourced last by `.zshrc`; secrets/API keys live here (gitignored) |
| `~/.p10k.zsh` | generated by `p10k configure` (gitignored) |
| `config/nvim/lazy-lock.json` | generated by LazyVim (gitignored) |

## Update and uninstall

```bash
git pull
make update          # zimfw modules + Lazy sync (+ Mason wait) + tmux framework
make nvim-sync       # only Neovim plugins/Mason
./scripts/uninstall.sh   # remove the symlinks this repo created
```

## Keymaps

### Neovim

| Key | Action |
|---|---|
| `<Space>ff` | find files |
| `<Space>fg` | live grep |
| `<Space>e` | file explorer |
| `<Space>fy` | Yazi |
| `<Space>cp` | Markdown preview (browser) |
| `<Space>st` | todo picker (fzf-lua, falls back to Telescope) |
| `<Space>xt` | todo in Trouble |
| `<C-h/j/k/l>` | window / tmux navigation |
| `<C-/>` | floating terminal |
| `gcc` | toggle line comment |
| `sa` / `sr` / `sd` | add / replace / delete surrounding |

### tmux

| Key | Action |
|---|---|
| `Ctrl+a` | prefix |
| `Ctrl+a \|` | split horizontally |
| `Ctrl+a -` | split vertically |
| `Ctrl+h/j/k/l` | pane navigation (Neovim aware) |
| `Alt+1~9` | switch window |
| `Ctrl+a y` | open Yazi |

### fzf

| Key | Action |
|---|---|
| `Ctrl+R` | command history |
| `Ctrl+T` | find files |
| `Alt+C` | change directory |
