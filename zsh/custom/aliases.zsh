# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias reloadcli="source $HOME/.zshrc"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias c="clear"
alias zbundle="antibody bundle < $DOTFILES/zsh_plugins.txt > $DOTFILES/zsh_plugins.sh"
alias editaliases='open -a "Visual Studio Code" ~/.aliases.zsh'
alias showpublickey='cat ~/.ssh/id_ed25519.pub'
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

# Composer
alias cda="composer dump-autoload -o"
alias c="composer"
alias cu="composer update"
alias cr="composer require"
alias ci="composer install"

# Laravel
alias pa="php artisan"
alias migrate="php artisan migrate"
alias seed="php artisan seed"
alias srv="php artisan serve"

# PHP
alias cfresh="rm -rf vendor/ composer.lock && composer i"

# JS
alias nfresh="rm -rf node_modules/ package-lock.json && npm install"
alias watch="npm run watch"

# PHPUnit
alias pu="vendor/bin/phpunit"
alias pf="pu --filter "
alias pg="pu --group "
alias pt="pu --testsuite "

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"
alias projects="cd $HOME/Projects"

# Vagrant
alias v="vagrant global-status"
alias vup="vagrant up"
alias vhalt="vagrant halt"
alias vssh="vagrant ssh"
alias vreload="vagrant reload"
alias vrebuild="vagrant destroy --force && vagrant up"

# Projects
alias ring="projects && cd ringside"
alias jeff="projects && cd jeffreydavidson.net"
alias cassie="projects && cd cassandradavidsonflautist.com"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
