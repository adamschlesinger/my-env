eval "$(oh-my-posh init zsh)"
eval "$(oh-my-posh init zsh --config $HOME/.custom.omp.yaml)"

fpath+=~/.zfunc

# autocomplete
source "$(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select

# brew completions
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Language environment
#export LANG=en_US.UTF-8
#export LANGUAGE=en_US.UTF-8
#export LC_ALL=en_US.UTF-8

# autojump https://github.com/wting/autojump
[ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh

# aliases
alias ls='lsd -A'
alias tree='ls --tree'
alias reload='source ~/.zshrc'
alias epoch='date +%s'
alias grep='grep --color=auto'
alias co='checkout'
alias filesizes='du -hs * | sort -h'
alias ack='ack --color'
alias vim="$(brew --prefix)/bin/vim"

# fzf
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
source <(fzf --zsh)

# java
export PATH="/$(brew --prefix openjdk)/bin:$PATH"
export CPPFLAGS="-I/$(brew --prefix openjdk)/include"

# python
export PATH="$(brew --prefix python)/libexec/bin:$PATH"

# ruby
eval "$(rbenv init - zsh)"

# iterm2 shell integrations
#test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# 1password
OP_BIOMETRIC_UNLOCK_ENABLED=true

# flex
export LDFLAGS="-L/$(brew --prefix flex)/lib"
export CPPFLAGS="-I/$(brew --prefix flex)/include"

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

# syntax highlighting
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# auto suggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Created by `pipx` on 2024-06-09 02:02:04
export PATH="$PATH:$HOME/.local/bin"

clear
fastfetch
