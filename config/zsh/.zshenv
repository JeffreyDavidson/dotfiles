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
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export DOTFILES="${HOME}/Projects/dotfiles"
export GIT_CONFIG="${XDG_CONFIG_HOME}/git/.gitconfig"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export LESSHISTFILE="{$XDG_STATE_HOME}/less/history" # Disable less history.
export N_PREFIX="${HOME}/.n"
export PREFIX="$N_PREFIX"
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/config.toml"
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export ZLIB="${ZDOTDIR}/lib"

export HOMEBREW_CASK_OPTS="--no-quarantine --no-binaries"
export HOMEBREW_NO_ENV_HINTS=1
