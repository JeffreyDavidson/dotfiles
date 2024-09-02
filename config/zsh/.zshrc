eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval $(thefuck --alias)
eval "$(thefuck --alias fk)"

source "$HOME/.shell/.path"
source "$HOME/.shell/.history"
source "$HOME/.shell/.exports"

# Directory for all-things ZSH config
zsh_dir=${${ZDOTDIR}:-$HOME/.config/zsh}

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
fi

source "$HOME/.shell/.functions"
source "$HOME/.shell/.completions"
source "$HOME/.shell/.keys"

source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

autoload -U compinit && compinit

test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
