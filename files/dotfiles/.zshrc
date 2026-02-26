BREW_PREFIX=$(brew --prefix)

eval "$(oh-my-posh init zsh --config $HOME/.custom.omp.yaml)"

# aliases
alias ls='lsd -A'
alias tree='ls --tree'
alias reload='source ~/.zshrc'
alias epoch='date +%s'
alias grep='grep --color=auto'
alias co='checkout'
alias filesizes='du -hs * | sort -h'
alias ack='ack --color'
alias vim="$BREW_PREFIX/bin/vim"
alias k='kubectl'

# autojump
# https://github.com/wting/autojump
[ -f $BREW_PREFIX/etc/profile.d/autojump.sh ] && . $BREW_PREFIX/etc/profile.d/autojump.sh

# 1password
OP_BIOMETRIC_UNLOCK_ENABLED=true

# man colors
export MANPAGER="$(where less) -s -M +Gg"
export LESS_TERMCAP_mb=$'\e[1;31m'      # begin bold
export LESS_TERMCAP_md=$'\e[1;34m'      # begin blink
export LESS_TERMCAP_so=$'\e[01;45;37m'  # begin reverse video
export LESS_TERMCAP_us=$'\e[01;36m'     # begin underline
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline
export GROFF_NO_SGR=1                   # for konsole

# custom completions
FPATH="$HOME/.zfunc:$FPATH"

# zsh-completions
FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH

# init completions
autoload -Uz compinit && compinit

# auto suggestions
# https://github.com/zsh-users/zsh-autosuggestions
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# syntax highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fzf
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
source <(fzf --zsh)

# android
export ANDROID_HOME="$BREW_PREFIX/share/android-commandlinetools"

clear
fastfetch
