# .zshrc
ZSH_BASE=$HOME/dotfiles/zsh # Base directory for ZSH configuration

# Load Aliases
source $ZSH_BASE/custom/aliases.zsh

# Load Paths
source $ZSH_BASE/custom/path.zsh

# Load Antigen
source $ZSH_BASE/custom/plugins/antigen/antigen.zsh

# Load Antigen configurations
antigen init $ZSH_BASE/.antigenrc
