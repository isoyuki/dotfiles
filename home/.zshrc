# Uncomment below if profiling the zsh startup
# zmodload zsh/zprof

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

source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

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
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# ── macOS-only paths & completions ───────────────────────────────────
if $IS_MACOS; then
  export PATH="$HOME/.duckdb/cli/latest:$PATH"

  # gcloud via homebrew
  if (( $+commands[brew] )); then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
  fi
fi

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Optimisation for compinit
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# Tool completions (guarded)
(( $+commands[jj] )) && source <(jj util completion zsh)

[ -f ~/.env.sh ] && source ~/.env.sh

# Uncomment below if profiling the zsh startup
# zprof
