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

# Customize Prompts
PROMPT='
%1! %L %# '

RPROMPT='%*'

# Add Locations to $PATH Variable
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:$N_PREFIX/bin"

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_";
}
