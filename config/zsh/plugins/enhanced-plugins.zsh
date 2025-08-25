# Enhanced ZSH Plugins Configuration
# Modern ZSH plugins for improved productivity and UX

# Check if antigen is available
if command -v antigen >/dev/null 2>&1; then
    
    # Load oh-my-zsh library
    antigen use oh-my-zsh
    
    #############################################################
    # Essential Productivity Plugins
    #############################################################
    
    # Auto-suggestions (fish-like autosuggestions)
    antigen bundle zsh-users/zsh-autosuggestions
    
    # Syntax highlighting (must be loaded after other plugins)
    antigen bundle zsh-users/zsh-syntax-highlighting
    
    # Completions
    antigen bundle zsh-users/zsh-completions
    
    # History substring search
    antigen bundle zsh-users/zsh-history-substring-search
    
    #############################################################
    # Oh-My-Zsh Plugins
    #############################################################
    
    # Git enhancements
    antigen bundle git
    antigen bundle gitfast
    antigen bundle git-extras
    
    # Directory navigation
    antigen bundle dirpersist
    antigen bundle last-working-dir
    
    # Development tools
    antigen bundle composer
    antigen bundle node
    antigen bundle npm
    
    # macOS specific
    antigen bundle macos
    antigen bundle brew
    
    # Utilities
    antigen bundle colored-man-pages
    antigen bundle command-not-found
    antigen bundle extract
    antigen bundle safe-paste
    antigen bundle web-search
    
    #############################################################
    # Third-party Plugins
    #############################################################
    
    # Enhanced cd with fuzzy matching
    antigen bundle changyuheng/fz
    
    # Kubernetes helpers (if you use k8s)
    # antigen bundle kubectl
    
    # AWS CLI helpers (if you use AWS)
    # antigen bundle aws
    
    # Apply all antigen configurations
    antigen apply
    
    #############################################################
    # Plugin Configuration
    #############################################################
    
    # Auto-suggestions configuration
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4C566A,underline"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    
    # Syntax highlighting configuration
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
    
    # Custom syntax highlighting styles (Nord theme)
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[default]='none'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#BF616A'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#5E81AC,bold'
    ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#A3BE8C,underline'
    ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#EBCB8B'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#A3BE8C,underline'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#D08770'
    ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#EBCB8B,underline'
    ZSH_HIGHLIGHT_STYLES[path]='underline'
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#D08770'
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#D08770'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=#B48EAD'
    ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#5E81AC'
    ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#D8DEE9'
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#4C566A'
    ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=#D8DEE9'
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#4C566A'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#81A1C1'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#81A1C1'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#B48EAD'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#4C566A'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#A3BE8C'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#A3BE8C'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#A3BE8C'
    ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#A3BE8C'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#EBCB8B'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#EBCB8B'
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#EBCB8B'
    ZSH_HIGHLIGHT_STYLES[assign]='fg=#D8DEE9'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#D8DEE9'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=#4C566A,bold'
    ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#D8DEE9'
    ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#D8DEE9'
    ZSH_HIGHLIGHT_STYLES[arg0]='fg=#D8DEE9'
    
    # History substring search configuration
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#434C5E,fg=#D8DEE9,bold'
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#BF616A,fg=#D8DEE9,bold'
    HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'
    
    # Key bindings for history substring search
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^P' history-substring-search-up
    bindkey '^N' history-substring-search-down
    
    # Key bindings for auto-suggestions
    bindkey '^ ' autosuggest-accept
    bindkey '^]' autosuggest-execute
    bindkey '^[f' forward-word
    
else
    echo "Antigen not found. Enhanced plugins not loaded."
    echo "Run your dotfiles installation to set up Antigen."
fi

#############################################################
# Additional Plugin Enhancements
#############################################################

# Enhanced completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches found%f'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Git completion enhancements
zstyle ':completion:*:*:git:*' script ~/.config/zsh/lib/git-completion.bash
zstyle ':completion:*:*:git:*' user-commands ${${(M)${(f)"$(git help -a 2>/dev/null)"}:#  [a-z]*}#  }

# Laravel Herd completions (if available)
if command -v herd >/dev/null 2>&1; then
    # Herd handles PHP/Laravel development environment
    zstyle ':completion:*:*:herd:*' option-stacking yes
fi

# FZF integration with plugins
if command -v fzf >/dev/null 2>&1; then
    # FZF + Git integration
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    
    # FZF key bindings for plugin compatibility
    bindkey '^T' transpose-chars  # Restore original Ctrl-T if needed
fi

# Load custom completions
fpath=(~/.config/zsh/completions $fpath)

# Initialize completion system if not already done
autoload -Uz compinit
compinit