# Set Variables
export HOMEBREW_CASK_OPTS="--no quarantine"
export NULLCMD=bat
export N_PREFIX="$HOME/.n"
export PREFIX="$N_PREFIX"

# Create Aliases
alias ls='eza -lAFh --git'
alias eza='eza -laFh --git'
alias man=batman
alias trail='<<<${(F)fpath}'
alias rm=trash
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias showpublickey='bat ~/.ssh/id_ed25519.pub'
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

# Git
alias gs="git status"
alias gb="git branch"
alias gl="git log"
alias gco="git checkout"
alias gcom="git checkout master"
alias gaa="git add ."
alias gc="git commit -m"
alias diff="git diff"
alias commit="git add . && git commit -m"
alias gp="git push"
alias force="git push --force"
alias nah="git reset --hard && git clean -df"
alias pop="git stash pop"
alias push="git push"
alias pull="git pull"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="git add . && git commit -m 'wip'"
alias oops="git reset --soft  HEAD~1"
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Remove branches that have already been merged with master
# a.k.a. ‘delete merged’
alias dm="git branch --merged | grep -vE 'main|master|development|\\*' | xargs -n 1 git branch -D"

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
alias mfs="php artisan migrate:fresh --seed"
alias sail="./vendor/bin/sail"

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

# Pest
alias pest="vendor/bin/pest"
alias pestf="pu --filter "
alias pestg="pu --group "
alias pestt="pu --testsuite "

# Larastan
alias larastan="vendor/bin/phpstan analyse"

# Directories
alias dotfiles="cd ~/.dotfiles"
alias library="cd $HOME/Library"
alias code="cd $HOME/Code"

# Vagrant
alias v="vagrant global-status"
alias vup="vagrant up"
alias vhalt="vagrant halt"
alias vssh="vagrant ssh"
alias vreload="vagrant reload"
alias vrebuild="vagrant destroy --force && vagrant up"

# Projects
alias ring="code && cd ringside"
alias jeff="code && cd jeffreydavidson.me"
alias cassie="code && cd cassandradavidsonflautist.com"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

eval "$(starship init zsh)"

neofetch

# Add Locations to $path Array
typeset -U path
path=(
  $path
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  "$N_PREFIX/bin"
)

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_";
}
