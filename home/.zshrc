# Uncomment below if profiling the zsh startup
# zmodload zsh/zprof

# ── Cached eval helper ───────────────────────────────────────────────
# Caches command output to a file, regenerates when the binary is updated.
_cached_eval() {
  local name="$1"; shift
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-eval-cache/$name"
  if [[ ! -s "$cache" || "${commands[$1]}" -nt "$cache" ]]; then
    command mkdir -p "${cache:h}"
    "$@" > "$cache"
  fi
  builtin source "$cache"
}

# ── Platform detection ────────────────────────────────────────────────
case "$(uname)" in
  Darwin) IS_MACOS=true  ;;
  *)      IS_MACOS=false ;;
esac

# ── macOS: Homebrew ───────────────────────────────────────────────────
if $IS_MACOS && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.config/oh-my-zsh/custom"

ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX=true

plugins=(
    git
    zsh-autosuggestions
    fast-syntax-highlighting
    zsh-vi-mode
    fzf-tab
    forgit
)

# Workaround to get zsh-vi-mode to not conflict with fzf
ZVM_INIT_MODE=sourcing
source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

_cached_eval fzf fzf --zsh
_cached_eval zoxide zoxide init zsh
_cached_eval mise mise activate zsh
_cached_eval direnv direnv hook zsh

setopt HIST_IGNORE_ALL_DUPS

# ── fzf defaults (use fd + bat) ──────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'ls -la --color=always {}'"

# ── fzf-tab: preview for tab completions ─────────────────────────────
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la --color=always $realpath'
zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --color=always --style=numbers $realpath 2>/dev/null || ls -la --color=always $realpath'
zstyle ':fzf-tab:complete:ssh:*' fzf-preview 'awk "/^Host $word/,/^Host /" ~/.ssh/config 2>/dev/null'
zstyle ':fzf-tab:complete:docker-*:*' fzf-preview 'docker inspect $word 2>/dev/null | head -40'
zstyle ':fzf-tab:complete:kubectl-*:*' fzf-preview 'kubectl describe $word 2>/dev/null | head -40'
zstyle ':fzf-tab:complete:kill:*' fzf-preview 'ps -p $word -o pid,user,%cpu,%mem,command 2>/dev/null'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'systemctl status $word 2>/dev/null'

alias vi="nvim"
alias lsd="lsd --icon=never"
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# ── macOS-only paths & completions ───────────────────────────────────
if $IS_MACOS; then
  export PATH="$HOME/.duckdb/cli/latest:$PATH"

  # gcloud via homebrew
  if (( $+commands[brew] )); then
    local _brew_prefix="${HOMEBREW_PREFIX:-$(brew --prefix)}"
    source "$_brew_prefix/share/google-cloud-sdk/path.zsh.inc"
    source "$_brew_prefix/share/google-cloud-sdk/completion.zsh.inc"
  fi
fi

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export GOPRIVATE=github.com/kouzoh/*

export EDITOR="nvim"
export VISUAL="nvim"

# export SRC_ACCESS_TOKEN=(your access token)

# Tool completions (guarded)
(( $+commands[jj] )) && _cached_eval jj-completion jj util completion zsh
if [[ -x /opt/homebrew/bin/wizcli ]]; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /opt/homebrew/bin/wizcli wizcli
fi

[ -f ~/.env.sh ] && source ~/.env.sh

# Uncomment below if profiling the zsh startup
# zprof
