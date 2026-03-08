# Uncomment below if profiling the zsh startup
# zmodload zsh/zprof

eval "$(/opt/homebrew/bin/brew shellenv)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
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
# source <(COMPLETE=zsh tms)

alias vi="nvim"
export PATH="$HOME/.local/bin:$PATH"

# opencode
export PATH=/Users/ykume/.opencode/bin:$PATH
# autoload -U compinit; compinit
# Optimisation for compinit
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# gcloud auto completion
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

[ -f ~/.env.sh ] && source ~/.env.sh

# Uncomment below if profiling the zsh startup
# zprof
