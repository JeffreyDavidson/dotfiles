##############################################################################
# ~/.config/zsh/.zshrc                                                       #
##############################################################################
# Imports all plugins, aliases, helper functions, and configurations         #
# After editing, re-source .zshrc for new changes to take effect             #
##############################################################################

# Directory for all-things ZSH config
zsh_dir=${${ZDOTDIR}:-$HOME/.config/zsh}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source all ZSH config files (if present)
if [[ -d $zsh_dir ]]; then
  # Import alias files
  source ${zsh_dir}/aliases/general.zsh
  source ${zsh_dir}/aliases/git.zsh
  source ${zsh_dir}/aliases/php.zsh
  source ${zsh_dir}/aliases/composer.zsh
  source ${zsh_dir}/aliases/laravel.zsh
  source ${zsh_dir}/aliases/pest.zsh
  source ${zsh_dir}/aliases/phpunit.zsh
  source ${zsh_dir}/aliases/github.zsh
  source ${zsh_dir}/aliases/security.zsh
  source ${zsh_dir}/aliases/dotfiles.zsh

  # Setup Antigen, and import plugins
  source ${zsh_dir}/helpers/setup-antigen.zsh
  source ${zsh_dir}/helpers/enhanced-plugins.zsh

  # Laravel Herd configuration
  source ${zsh_dir}/helpers/herd.zsh

  # Configure ZSH stuff
  source ${zsh_dir}/lib/colors.zsh
  source ${zsh_dir}/lib/history.zsh
  source ${zsh_dir}/lib/completion.zsh
  source ${zsh_dir}/lib/navigation.zsh
  source ${zsh_dir}/lib/key-bindings.zsh
fi

# Add Locations to $path Array
typeset -U path

path=(
  "${XDG_BIN_HOME:-$HOME/.local/bin}"
  $path
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
)

# Tool initialization
eval "$(fzf --zsh)"
source ${XDG_CONFIG_HOME:-$HOME/.config}/fzf/fzf.zsh
eval "$(thefuck --alias)"
eval "$(starship init zsh)"

# Initialize zoxide quietly, skip during plugin updates to avoid conflicts
if command -v zoxide >/dev/null 2>&1 && [[ -z "$ANTIGEN_UPDATING" ]]; then
  eval "$(zoxide init --cmd cd zsh)" 2>/dev/null || true
fi
source ${XDG_CONFIG_HOME:-$HOME/.config}/zoxide/zoxide.zsh

# 1Password SSH agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
