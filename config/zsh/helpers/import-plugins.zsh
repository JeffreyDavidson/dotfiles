#!/usr/bin/env zsh

# Syntax highlighting for commands
antigen bundle zsh-users/zsh-syntax-highlighting

# Quickly jump into frequently used directories
antigen bundle agkozak/zsh-z

# Replace zsh default completion menu with fzf
antigen bundle Aloxaf/fzf-tab

# Remind you to use existing aliases
antigen bundle MichaelAquilina/zsh-you-should-use

# Search history
antigen bundle zsh-users/zsh-history-substring-search

# Extra zsh completions
antigen bundle zsh-users/zsh-completions

# Auto suggestions from history
antigen bundle zsh-users/zsh-autosuggestions

# Tell antigen that you're done
antigen apply
