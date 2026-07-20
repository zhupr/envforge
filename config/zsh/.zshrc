# Enable Powerlevel10k instant prompt. Must stay near the top of .zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------
# Zsh configuration
# -----------------

# History
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
HISTSIZE=100000
SAVEHIST=100000

# Input
bindkey -e
WORDCHARS=${WORDCHARS//[\/]}

# --------------------
# Module configuration
# --------------------

# zsh-autosuggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# ------------------
# Initialize zimfw
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
# Prevent "completion already initialized" warning
(( ${+_comps} )) && unset _comps
source ${ZIM_HOME}/init.zsh

# ------------------
# Powerlevel10k
# ------------------
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ------------------
# FZF-Tab config
# ------------------
zstyle ':completion:*:git-log*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

# ------------------
# fzf config
# ------------------

# fzf shell integration (Ctrl+R, Ctrl+T, Alt+C)
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border --inline-info
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#24283b,hl+:#bb9af7
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#7aa2f7
'
_fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1"; }
_fzf_compgen_dir() { fd --type d --hidden --follow --exclude ".git" . "$1"; }

# fzf-tab preview
zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -d $realpath ]] && eza -1 --color=always $realpath || bat --color=always --style=numbers $realpath 2>/dev/null'

# ------------------
# Modern CLI aliases
# ------------------

# eza
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza -la --icons --tree --level=2 --git'
alias la='eza -a --icons --group-directories-first'

# bat
alias cat='bat --paging=never --style=plain'
alias catp='bat --paging=auto --style=numbers,changes'

# ripgrep
alias grep='rg --color=auto'

# fd
alias find='fd'

# ------------------
# Other tools
# ------------------

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# PATH additions
export PATH="$HOME/.local/bin:$PATH"

# Go
[[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$GOPATH/bin:$PATH"

# vcpkg
[[ -d "$HOME/.local/share/vcpkg" ]] && export VCPKG_ROOT="$HOME/.local/share/vcpkg"
[[ -n "${VCPKG_ROOT:-}" ]] && export PATH="$VCPKG_ROOT:$PATH"

# nvm & conda: lazy-load with zsh-defer
_init_conda() {
  local conda_exe=""
  for candidate in "$HOME/miniconda3/bin/conda" "$HOME/anaconda3/bin/conda" "$(command -v conda 2>/dev/null)"; do
    if [[ -x "$candidate" ]]; then
      conda_exe="$candidate"
      break
    fi
  done
  if [[ -n "$conda_exe" ]]; then
    eval "$("$conda_exe" 'shell.zsh' 'hook' 2>/dev/null)"
  fi
  unfunction _init_conda 2>/dev/null
}

if (( $+functions[zsh-defer] )); then
  zsh-defer source "$HOME/.nvm/nvm.sh" 2>/dev/null
  zsh-defer source "$HOME/.nvm/bash_completion" 2>/dev/null
  zsh-defer _init_conda
else
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  _init_conda
fi

# Load local overrides if present (machine-specific settings, API keys, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
