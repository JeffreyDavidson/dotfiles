echo 'Hello from .zshrc'

# Set variables
export HOMEBREW_CASK_OPTS="--no-quarantine"

# Change ZSH Options

# Create Aliases
alias ls='eza'
alias eza='eza -lah --git'
alias man='batman'

# Customize Prompt(s)

# Add locations to $PATH Variable
# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_"; 
}
# Use ZSH Plugins

# ...and Other Surprises
