#!/bin/bash

# Install Git Hooks Script
# Sets up git hooks for dotfiles validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if we're in a git repository
if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
    log_error "Not in a git repository: $DOTFILES_DIR"
    exit 1
fi

# Install git hooks
install_hooks() {
    log_info "Installing git hooks..."
    
    local git_hooks_dir="$DOTFILES_DIR/.git/hooks"
    local source_hooks_dir="$DOTFILES_DIR/.githooks"
    
    # Create hooks directory if it doesn't exist
    mkdir -p "$git_hooks_dir"
    
    # Install pre-commit hook
    if [[ -f "$source_hooks_dir/pre-commit" ]]; then
        cp "$source_hooks_dir/pre-commit" "$git_hooks_dir/pre-commit"
        chmod +x "$git_hooks_dir/pre-commit"
        log_success "Pre-commit hook installed"
    else
        log_warning "Pre-commit hook not found in $source_hooks_dir"
    fi
    
    # Install other hooks if they exist
    for hook_file in "$source_hooks_dir"/*; do
        if [[ -f "$hook_file" && "$(basename "$hook_file")" != "pre-commit" ]]; then
            local hook_name="$(basename "$hook_file")"
            cp "$hook_file" "$git_hooks_dir/$hook_name"
            chmod +x "$git_hooks_dir/$hook_name"
            log_success "$hook_name hook installed"
        fi
    done
}

# Test hooks installation
test_hooks() {
    log_info "Testing hooks installation..."
    
    local git_hooks_dir="$DOTFILES_DIR/.git/hooks"
    
    if [[ -x "$git_hooks_dir/pre-commit" ]]; then
        log_success "Pre-commit hook is installed and executable"
        
        # Test hook execution (dry run)
        log_info "Testing pre-commit hook..."
        if cd "$DOTFILES_DIR" && "$git_hooks_dir/pre-commit" 2>/dev/null; then
            log_success "Pre-commit hook test passed"
        else
            log_warning "Pre-commit hook test had issues (this might be normal if no files are staged)"
        fi
    else
        log_error "Pre-commit hook installation failed"
        exit 1
    fi
}

# Configure git to use hooks
configure_git() {
    log_info "Configuring git hooks..."
    
    cd "$DOTFILES_DIR"
    
    # Set hooks path (optional - for custom hooks directory)
    # git config core.hooksPath .githooks
    
    log_success "Git hooks configured"
}

# Main installation
main() {
    log_info "Setting up git hooks for dotfiles..."
    
    install_hooks
    test_hooks
    configure_git
    
    log_success "Git hooks setup completed!"
    log_info "Your commits will now be validated automatically"
    
    echo ""
    echo "Installed hooks:"
    echo "  - pre-commit: Validates YAML, JSON, shell scripts, and checks for sensitive data"
    echo ""
    echo "To bypass hooks (emergency only): git commit --no-verify"
}

# Handle script arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        echo "Usage: $0 [help]"
        echo ""
        echo "Installs git hooks for dotfiles validation."
        echo "Hooks will automatically validate your commits."
        exit 0
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown argument: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac