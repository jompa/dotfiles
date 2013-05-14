set -o emacs

alias c='clear'
alias o='open'
alias e='vim'
alias h='history'
alias hg='history | grep'

alias gs='git status'
alias gc='git commit'

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

#http://tooky.github.com/2010/04/08/there-was-a-problem-with-the-editor-vi-git-on-mac-os-x.html
export EDITOR=/usr/bin/vim

alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -lh'
alias tig='tig status'
