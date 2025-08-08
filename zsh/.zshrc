# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$HOME/go/bin:$PATH

# Go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go

export PATH=$PATH:/usr/local/bin
export PATH=$PATH:$CUDA_HOME/bin
export PATH=$PATH:~/.config/emacs/bin

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/home/wren/.oh-my-zsh/completions/_bun" ] && source "/home/wren/.oh-my-zsh/completions/_bun"

export ZSH="$HOME/.oh-my-zsh"
export EDITOR=/usr/bin/vim
export VISUAL=$EDITOR

ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_CUSTOM=/home/wren/.config/oh-my-zsh/custom

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting docker z zsh-vi-mode fzf)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U +X bashcompinit && bashcompinit

complete -o nospace -C /usr/bin/terraform terraform

export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64

export GTK_THEME=Adwaita:dark
