##############################################################################
# ~/.config/zsh/.zshrc                                                       #
##############################################################################
# Instructions to be executed when a new ZSH session is launched             #
# Imports all plugins, aliases, helper functions, and configurations         #
#                                                                            #
# After editing, re-source .zshrc for new changes to take effect             #
# For docs and more info, see: https://github.com/jeffreydavidson/dotfiles   #
##############################################################################
# Licensed under MIT (C) Jeffrey Davidson 2024                               #
##############################################################################

# Directory for all-things ZSH config
zsh_dir=${${ZDOTDIR}:-$HOME/.config/zsh}
utils_dir="${XDG_CONFIG_HOME}/utils"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Import utility functions (if present)
if [[ -d $utils_dir ]]; then
  source ${utils_dir}/welcome-banner.sh
  source ${utils_dir}/color-map.sh
fi

# MacOS-specific services
if [ "$(uname -s)" = "Darwin" ]; then
  # Homebrew PATH is handled by .zprofile
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
  source ${zsh_dir}/helpers/enhanced-plugins.zsh
  source ${zsh_dir}/helpers/fallbacks.zsh

  # Laravel Herd configuration
  source ${zsh_dir}/helpers/herd.zsh

   # Configure ZSH stuff
  source ${zsh_dir}/lib/colors.zsh
  source ${zsh_dir}/lib/history.zsh
  source ${zsh_dir}/lib/completion.zsh
  source ${zsh_dir}/lib/navigation.zsh
  source ${zsh_dir}/lib/key-bindings.zsh
fi

# Zoxide initialization is handled below with starship and other tools

# If not running in nested shell, then show welcome message :)
if [[ "${SHLVL}" -lt 2 ]] && \
  { [[ -z "$SKIP_WELCOME" ]] || [[ "$SKIP_WELCOME" == "false" ]]; }; then
  welcome
fi

# Add Locations to $path Array
typeset -U path

path=(
  $path
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
)

# compinit is handled in lib/completion.zsh

eval "$(fzf --zsh)"
eval "$(starship init zsh)"
# Initialize zoxide quietly, but skip during plugin updates to avoid conflicts
if command -v zoxide >/dev/null 2>&1 && [[ -z "$ANTIGEN_UPDATING" ]]; then
  eval "$(zoxide init --cmd cd zsh)" 2>/dev/null || true
fi

export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# Note: dircolors configuration handled in lib/colors.zsh using XDG-compliant location

# Note: Laravel Herd configuration has been moved to helpers/herd.zsh for better organization
