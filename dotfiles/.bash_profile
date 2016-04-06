##
## ENVIRONMENT
##
export USERNAMES="james jmalloc"
export DOTFILES_PATH="$HOME/dotfiles"                # The path to the clone of this repo.
export GIT_PATH="$HOME/dev/git"                      # The target for 'git cl' clones.
export GOPATH="$HOME/dev/go"
export GIT_SEARCH="$GOPATH/src/github.com $GIT_PATH" # Search paths for 'git cd'.
export PATH="$DOTFILES_PATH/bin:$HOME/bin:$HOME/.gem/ruby/2.0.0/bin:$GOPATH/bin:$PATH"
export HISTCONTROL="ignoreboth"

ulimit -n 8192

##
## ALIASES
##
alias g='git'
alias m='make'
alias less='less -R'
alias grep='grep --color'
alias cov='open artifacts/tests/coverage/index.html'

if [[ $(uname) == "Darwin" ]]; then
    alias ls='ls -lhG'
else
    alias ls='ls -lh --color --group-directories-first'
fi

type -t brew > /dev/null && source $(brew --prefix)/etc/bash_completion

##
## TEXT EDITOR
##
if type -t atom > /dev/null; then
    alias e='atom .'
    export VISUAL='atom -w'
elif [ -d "/Applications/Sublime Text.app/Contents/SharedSupport/bin" ]; then
	export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
    alias e='subl .'
    export VISUAL='subl -w'

    SUBLIME_USER_DIR="/Users/james/Library/Application Support/Sublime Text 3/Packages/User"
    if [ -d "$SUBLIME_USER_DIR" ]; then
        mv "$SUBLIME_USER_DIR" "$SUBLIME_USER_DIR.local"
    fi

    if [ ! -e "$SUBLIME_USER_DIR" ]; then
        ln -s "~/Library/Mobile\ Documents/com~apple~CloudDocs/sublime" "$SUBLIME_USER_DIR"
    fi
else
    export VISUAL="vim"
fi

export EDITOR="$VISUAL"
git config --global core.editor "$VISUAL"

##
## Source other bash scripts ...
##
for FILE in "$DOTFILES_PATH/lib/"*.bash; do
    source $FILE
done

[ -f ~/.bashrc ] && source ~/.bashrc

##
## .bashrc SHOULD set the GITHUB_TOKEN environment variable st
##
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Warning: GITHUB_TOKEN is not set."
else
    export HOMEBREW_GITHUB_API_TOKEN="$GITHUB_TOKEN"
    type -t composer > /dev/null && \
        composer config --global -- github-oauth.github.com "$GITHUB_TOKEN"
fi
