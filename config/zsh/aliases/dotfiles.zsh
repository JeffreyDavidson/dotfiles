# Dotfiles Management Aliases
# Simple shortcuts for managing your dotfiles

# Navigate to dotfiles directory
alias dotfiles="cd ${DOTFILES:-$HOME/Projects/dotfiles}"
alias dots="dotfiles"

# Quick updates
alias update-dotfiles="cd ${DOTFILES:-$HOME/Projects/dotfiles} && git pull"
alias backup-dotfiles="${DOTFILES:-$HOME/Projects/dotfiles}/scripts/backup.sh"

# Git shortcuts for dotfiles
alias dfstatus="cd ${DOTFILES:-$HOME/Projects/dotfiles} && git status"
alias dfpush="cd ${DOTFILES:-$HOME/Projects/dotfiles} && git add . && git commit -m 'Update dotfiles' && git push"
alias dflog="cd ${DOTFILES:-$HOME/Projects/dotfiles} && git log --oneline -10"

# Re-run installation
alias install-dotfiles="${DOTFILES:-$HOME/Projects/dotfiles}/install.sh"
alias setup-dotfiles="${DOTFILES:-$HOME/Projects/dotfiles}/scripts/setup.sh"

# Edit common configurations
alias edit-zsh="code ${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
alias edit-git="code ${XDG_CONFIG_HOME:-$HOME/.config}/git"
alias edit-starship="code ${XDG_CONFIG_HOME:-$HOME/.config}/starship/config.toml"

# Quick reload
alias reload-shell="source ~/.zshenv && source ${ZDOTDIR:-$HOME}/.zshrc"

# System info
alias sysinfo="echo 'System: $(uname -a)' && echo 'Shell: $SHELL' && echo 'Dotfiles: ${DOTFILES:-$HOME/Projects/dotfiles}'"

# Show dotfiles structure
dotfiles-tree() {
    local dotfiles_dir="${DOTFILES:-$HOME/Projects/dotfiles}"
    if command -v eza >/dev/null 2>&1; then
        eza --tree "$dotfiles_dir" -L 2 --icons
    elif command -v tree >/dev/null 2>&1; then
        tree "$dotfiles_dir" -L 2
    else
        find "$dotfiles_dir" -maxdepth 2 -type d | head -20
    fi
}

# Quick check of symlinks
check-symlinks() {
    echo "🔗 Checking important symlinks..."
    
    local links=(
        "$HOME/.zshenv"
        "${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
        "${XDG_CONFIG_HOME:-$HOME/.config}/git"
        "${XDG_CONFIG_HOME:-$HOME/.config}/starship"
    )
    
    for link in "${links[@]}"; do
        if [[ -L "$link" ]]; then
            echo "✅ $link"
        elif [[ -e "$link" ]]; then
            echo "⚠️ $link (not a symlink)"
        else
            echo "❌ $link (missing)"
        fi
    done
}

# Show what's new in dotfiles
dotfiles-status() {
    local dotfiles_dir="${DOTFILES:-$HOME/Projects/dotfiles}"
    
    if [[ ! -d "$dotfiles_dir/.git" ]]; then
        echo "❌ Not a git repository: $dotfiles_dir"
        return 1
    fi
    
    cd "$dotfiles_dir"
    
    echo "📁 Dotfiles Directory: $dotfiles_dir"
    echo "🌿 Branch: $(git branch --show-current)"
    echo ""
    
    if ! git diff --quiet; then
        echo "📝 Modified files:"
        git diff --name-only
        echo ""
    fi
    
    local untracked=$(git ls-files --others --exclude-standard)
    if [[ -n "$untracked" ]]; then
        echo "🆕 Untracked files:"
        echo "$untracked"
        echo ""
    fi
    
    if git diff --quiet && [[ -z "$untracked" ]]; then
        echo "✅ Repository is clean"
    fi
    
    echo "📊 Recent commits:"
    git log --oneline -5
}

# Simple dotfiles help
dotfiles-help() {
    echo "🔧 Dotfiles Management Commands"
    echo "================================"
    echo ""
    echo "Navigation:"
    echo "  dotfiles, dots     - Go to dotfiles directory"
    echo "  dotfiles-tree      - Show directory structure"
    echo ""
    echo "Management:"
    echo "  update-dotfiles    - Pull latest changes"
    echo "  backup-dotfiles    - Create backup"
    echo "  install-dotfiles   - Re-run installation"
    echo "  setup-dotfiles     - Full setup script"
    echo ""
    echo "Status & Info:"
    echo "  dotfiles-status    - Show git status and info"
    echo "  check-symlinks     - Verify symlinks"
    echo "  sysinfo           - Show system information"
    echo ""
    echo "Editing:"
    echo "  edit-zsh          - Edit ZSH configuration"
    echo "  edit-git          - Edit Git configuration"
    echo "  edit-starship     - Edit Starship prompt"
    echo ""
    echo "Shortcuts:"
    echo "  dfstatus          - Git status"
    echo "  dfpush            - Add, commit, and push"
    echo "  dflog             - Show recent commits"
    echo "  reload-shell      - Reload shell configuration"
}