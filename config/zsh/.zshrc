##############################################################################
# ~/.config/zsh/.zshrc                                                       #
##############################################################################
# Instructions to be executed when a new ZSH session is launched             #
# Imports all plugins, aliases, helper functions, and configurations         #
#                                                                            #
# After editing, re-source .zshrc for new changes to take effect             #
# For docs and more info, see: https://github.com/jeffreydavidson/dotfiles   #
######################################################################
# Licensed under MIT (C) Jeffrey Davidson 2024                       #
######################################################################

eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval $(thefuck --alias)
eval "$(thefuck --alias fk)"

source "$HOME/.shell/.path"
source "$HOME/.shell/.functions"

# Directory for all-things ZSH config
zsh_dir=${${ZDOTDIR}:-$HOME/.config/zsh}
utils_dir="${XDG_CONFIG_HOME}/utils"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Import utility functions (if present)
if [[ -d $utils_dir ]]; then
  source ${utils_dir}/transfer.sh
  source ${utils_dir}/matrix.sh
  source ${utils_dir}/hr.sh
  source ${utils_dir}/web-search.sh
  source ${utils_dir}/am-i-online.sh
  source ${utils_dir}/welcome-banner.sh
  source ${utils_dir}/color-map.sh
fi

# MacOS-specific services
if [ "$(uname -s)" = "Darwin" ]; then
  # Add Brew to path, if it's installed
  if [[ -d /opt/homebrew/bin ]]; then
    export PATH=/opt/homebrew/bin:$PATH
  fi

  # If using iTerm, import the shell integration if availible
  if [[ -f "${XDG_CONFIG_HOME}/zsh/.iterm2_shell_integration.zsh" ]]; then
    source "${XDG_CONFIG_HOME}/zsh/.iterm2_shell_integration.zsh"
  fi
fi

# Source all ZSH config files (if present)
if [[ -d $zsh_dir ]]; then
  # Import alias files
  source ${zsh_dir}/aliases/general.zsh
  source ${zsh_dir}/aliases/git.zsh
  source ${zsh_dir}/aliases/node-js.zsh
  source ${zsh_dir}/aliases/php.zsh
  source ${zsh_dir}/aliases/composer.zsh
  source ${zsh_dir}/aliases/laravel.zsh
  source ${zsh_dir}/aliases/pest.zsh
  source ${zsh_dir}/aliases/phpunit.zsh
  source ${zsh_dir}/aliases/vagrant.zsh

  # Setup Antigen, and import plugins
  source ${zsh_dir}/helpers/setup-antigen.zsh
  source ${zsh_dir}/helpers/import-plugins.zsh
  source ${zsh_dir}/helpers/misc-stuff.zsh

   # Configure ZSH stuff
  source ${zsh_dir}/lib/colors.zsh
  source ${zsh_dir}/lib/history.zsh
  source ${zsh_dir}/lib/completion.zsh
  source ${zsh_dir}/lib/navigation.zsh
  source ${zsh_dir}/lib/key-bindings.zsh
fi

# Add Zoxide (for cd, quick jump) to shell
if hash zoxide 2> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# If not running in nested shell, then show welcome message :)
if [[ "${SHLVL}" -lt 2 ]] && \
  { [[ -z "$SKIP_WELCOME" ]] || [[ "$SKIP_WELCOME" == "false" ]]; }; then
  welcome
fi

autoload -U compinit && compinit

test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
