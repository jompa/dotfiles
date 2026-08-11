set -o emacs

alias c='clear'
alias o='open'
alias e='vim'
alias h='history'
alias hg='history | grep'

# Git aliases
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gap='git add -p'
alias gc='git commit'
alias gpull='git pull'
alias gpush='git push'
alias lns="ln -s"

# Virtualenv python 2.7.3
alias mkve='mkvirtualenv --no-site-packages --python=/usr/local/Cellar/python/2.7.3/bin/python'

alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

#we reset the prompt since the zsh formatting codes messes up the debug page otherwise
alias rs='PS1="" ./manage.py runserver'
alias sp='./manage.py shell_plus --plain'
alias p='ipython'

alias tx='tar -xvzf'
alias tc='tar -cvzf'

#misc
#alias v='vagrant'
alias vagrant='nocorrect vagrant'
alias tree='nocorrect tree'
alias gx='gitx --all'
alias gk='gitk --all &'

# Not an absolute path: pinning /usr/bin/vim would force the older system vim
# (9.1) for git and friends while the interactive `vim` resolves to Homebrew's
# 9.2, which PATH now prefers.
export EDITOR=vim

alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -lh'
alias tig='tig status'
