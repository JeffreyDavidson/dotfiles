#!/usr/bin/env zsh

# Quickly jump into frequently used directories
antigen bundle agkozak/zsh-z

# Replace zsh default completion menu with fzf
antigen bundle Aloxaf/fzf-tab

# Run mkdir and cd in one command
antigen bundle caarlos0/zsh-mkc

# Remind you to use existing aliases
antigen bundle MichaelAquilina/zsh-you-should-use

# Run artisan from anywhere in a directory
antigen bundle jessarcher/zsh-artisan

# Open current repository in browser
antigen bundle paulirish/git-open

# Auto suggestions from history
antigen bundle zsh-users/zsh-autosuggestions

# Extra zsh completions
antigen bundle zsh-users/zsh-completions

# Search history
antigen bundle zsh-users/zsh-history-substring-search

# Syntax highlighting for commands
antigen bundle zsh-users/zsh-syntax-highlighting

# Tell antigen that you're done
antigen apply
