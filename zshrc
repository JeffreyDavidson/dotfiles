# Set Variables


# Create Aliases
alias ls='ls -lAFh'

# Customize Prompts
PROMPT='
%1! %L %# '

RPROMPT='%*'


# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_";
}
