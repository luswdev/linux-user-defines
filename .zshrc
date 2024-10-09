ZSH_DISABLE_COMPFIX=true
# DISABLE_AUTO_UPDATE="true"
HISTFILE="/home/${USERNAME}/.cache/zsh/.zsh_history"

ZSH_THEME="jtriley-custom"

export ZSH=~/.oh-my-zsh
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

if [ -z "$ZSH_COMPDUMP" ]; then
  ZSH_COMPDUMP="${ZDOTDIR:-${ZSH}}/.cache/zsh/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
fi

[ -e ~/.dircolors ] && eval $(dircolors -b ~/.dircolors) ||
        eval $(dircolors -b)

plugins=(
	git
    	zsh-autosuggestions
    	zsh-syntax-highlighting
   	autojump
    	command-not-found
    	you-should-use
   # wakatime
)

export TERM=xterm-256color
export CCACHE_DIR=/home/${USERNAME}/.cache/ccache

[[ -n $TMUX ]] && export TERM="xterm-256color"

[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && . ~/.autojump/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u

source $ZSH/oh-my-zsh.sh

alias cl='clear'
alias df='df -h'
alias qq='exit'
alias zshref='source ~/.zshrc'
alias tmuxref='tmux source ~/.tmux.conf'

sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

