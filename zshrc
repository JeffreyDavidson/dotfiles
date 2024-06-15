# Set variables
export NULLCMD=bat
export HOMEBREW_CASK_OPTS="--no-quarantine"
export N_PREFIX="$HOME/.n"
export PREFIX="$N_PREFIX"

# Change ZSH Options

# Create Aliases
alias ls='eza'
alias eza='eza -lah --git'
alias man='batman'
alias trail='<<<${(F)path}'

# Customize Prompt(s)

# Add locations to $PATH Variable
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:$N_PREFIX/bin"

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_"; 
}
# Use ZSH Plugins

# ...and Other Surprises
