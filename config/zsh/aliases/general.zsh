# General
alias ls='eza'
alias eza='eza -lah --git --icons --color=always --long --no-filesize --no-time --no-user --no-permissions'
alias tree='eza --tree'
alias man='batman'
alias trail='<<<${(F)path}'
alias rm=trash
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias showpublickey='bat ~/.ssh/id_ed25519.pub'
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"
alias v="nvim"

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
