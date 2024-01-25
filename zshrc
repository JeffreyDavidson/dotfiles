# Set Variables
export HOMEBREW_CASK_OPTS="--no quarantine"

# Create Aliases
alias ls='eza -lAFh --git'
alias eza='eza -laFh --git'
alias man=batman

# Customize Prompts
PROMPT='
%1! %L %# '

RPROMPT='%*'

# Add Locations to $PATH Variable
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_";
}
