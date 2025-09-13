#  ~/.zshenv
# Core envionmental variables
# Locations configured here are requred for all other files to be correctly imported

# Set XDG directories
export XDG_BIN_HOME="${HOME}/.local/bin"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_LIB_HOME="${HOME}/.local/lib"
export XDG_STATE_HOME="${HOME}/.local/state"

# Set default applications
export EDITOR="vim"
export TERMINAL="warp"
export BROWSER="firefox"
export PAGER="less"
export NULLCMD=bat

## Respect XDG directories
export ADOTDIR="${XDG_CACHE_HOME}/zsh/antigen"
export ANDROID_USER_HOME="${XDG_DATA_HOME}/android"
export DOTFILES="${HOME}/dotfiles"
export GIT_CONFIG="${XDG_CONFIG_HOME}/git/.gitconfig"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export LESSHISTFILE="${XDG_STATE_HOME}/less/history" # Disable less history.
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/config.toml"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export ZLIB="${ZDOTDIR}/lib"

export HOMEBREW_CASK_OPTS="--no-quarantine --no-binaries"
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_BUNDLE_FILE="${XDG_CONFIG_HOME}/Brewfile"

# Additional XDG compliance for applications
export VIMINIT='source $XDG_CONFIG_HOME/vim/vimrc'
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export _Z_DATA="$XDG_STATE_HOME/z/data"

# Development tools XDG compliance
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export COMPOSER_HOME="$XDG_CONFIG_HOME/composer"

# Enhanced shell tools
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
export TMUX_CONFIG="${XDG_CONFIG_HOME}/tmux/tmux.conf"
export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"

# GPG, SSH, and Docker
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export SSH_CONFIG_FILE="${XDG_CONFIG_HOME}/ssh/config"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
