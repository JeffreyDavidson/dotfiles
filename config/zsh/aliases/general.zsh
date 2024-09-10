command_exists () {
  hash "$1" 2> /dev/null
}

# If exa installed, then use exa for some ls commands
if command_exists eza ; then
  alias ls='eza'
  alias eza='eza -lah --git --icons --color=always --long --no-filesize --no-time --no-user --no-permissions'
  alias l='eza -aF --icons' # Quick ls
  alias la='eza -aF --icons' # List all
  alias ll='eza -laF --icons' # Show details
  alias lm='eza -lahr --color-scale --icons -s=modified' # Recent
  alias lb='eza -lahr --color-scale --icons -s=size' # Largest / size
  alias tree='f() { eza -aF --tree -L=${1:-2} --icons };f'
else
  alias la='ls -A' # List all files/ includes hidden
  alias ll='ls -lAFh' # List all files, with full details
  alias lb='ls -lhSA' # List all files sorted by biggest
  alias lm='ls -tA -1' # List files sorted by last modified
fi

# List contents of packed file, depending on type
ls-archive () {
  if [ -z "$1" ]; then
    echo "No archive specified"
    return;
  fi
  if [[ ! -f $1 ]]; then
    echo "File not found"
    return;
  fi
  ext="${1##*.}"
  if [ $ext = 'zip' ]; then
    unzip -l $1
  elif [ $ext = 'rar' ]; then
    unrar l $1
  elif [ $ext = 'tar' ]; then
    tar tf $1
  elif [ $ext = 'tar.gz' ]; then
    echo $1
  elif [ $ext = 'ace' ]; then
    unace l $1
  else
    echo "Unknown Archive Format"
  fi
}

alias lz='ls-archive'

# Make directory, and cd into it
mkcd() {
  local dir="$*";
  mkdir -p "$dir" && cd "$dir";
}

# Make dir and copy
mkcp() {
  local dir="$2"
  local tmp="$2"; tmp="${tmp: -1}"
  [ "$tmp" != "/" ] && dir="$(dirname "$2")"
  [ -d "$dir" ] ||
    mkdir -p "$dir" &&
    cp -r "$@"
}

# Move dir and move into it
mkmv() {
  local dir="$2"
  local tmp="$2"; tmp="${tmp: -1}"
  [ "$tmp" != "/" ] && dir="$(dirname "$2")"
  [ -d "$dir" ] ||
      mkdir -p "$dir" &&
      mv "$@"
}

if command_exists trash; then
  alias rm=trash
fi

if command_exists batman; then
  alias man=batman
fi

if command_exists nvim; then
  alias v=nvim
fi

# Use color diff, if availible
if command_exists colordiff ; then
  alias diff='colordiff'
fi

# Find + manage aliases
alias al='alias | less' # List all aliases
alias as='alias | grep' # Search aliases
alias ar='unalias' # Remove given alias

# Copy / pasting
alias cpwd='pwd | pbcopy' # Copy current path
alias pa='pbpaste' # Paste clipboard contents

# App Specific
if command_exists code ; then; alias vsc='code .'; fi # Launch VS Code in current dir

# External Services
alias myip='curl icanhazip.com'
alias weather='curl wttr.in'
alias weather-short='curl "wttr.in?format=3"'

# Random lolz
alias cls='clear;ls' # Clear and ls
alias plz="fc -l -1 | cut -d' ' -f2- | xargs sudo" # Re-run last cmd as root

# Directories
alias library="cd $HOME/Library"

# Alias for install script
alias dotfiles="${DOTFILES_DIR:-$HOME/Projects/dotfiles}/install.sh"
alias dots="dotfiles"

# Command line history
alias h='history' # Shows full history
alias h-search='fc -El 0 | grep' # Searches for a word in terminal history
alias top-history='history 0 | awk '{print $2}' | sort | uniq -c | sort -n -r | head'
alias histrg='history -500 | rg' # Rip grep search recent history

alias trail='<<<${(F)path}'
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias showpublickey='bat ~/.ssh/id_ed25519.pub'
alias showFiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hideFiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"
alias v="nvim"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
