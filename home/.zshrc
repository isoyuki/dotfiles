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
)

# Workaround to get zsh-vi-mode to not conflict with fzf
ZVM_INIT_MODE=sourcing
source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"
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
