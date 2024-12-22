# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# java
export PATH="/$(brew --prefix openjdk)/bin:$PATH"
export CPPFLAGS="-I/$(brew --prefix openjdk)/include"

# ruby
eval "$(rbenv init - zsh)"

# flex
export LDFLAGS="-L/$(brew --prefix flex)/lib"
export CPPFLAGS="-I/$(brew --prefix flex)/include"