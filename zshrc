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

eval "$(starship init zsh)"

# Add Locations to $path Array
typeset -U path
path=(
  $path
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  "$N_PREFIX/bin"
)

# Write Handy Functions
function mkcd() {
  mkdir -p "$@" && cd "$_";
}
