echo 'Hello from .zshrc'

# Set variables
# Syntax highlighting for man pages using bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Change ZSH Options

# Create Aliases
alias ls='ls -lAFh'

# Customize Prompt(s)

# Add locations to $PATH Variable

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_"; 
}
# Use ZSH Plugins

# ...and Other Surprises
