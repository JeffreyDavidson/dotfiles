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

# Customize Prompts
PROMPT='
%1! %L %# '

RPROMPT='%*'

# Add Locations to $PATH Variable
export PATH="$N_PREFIX/bin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_";
}
