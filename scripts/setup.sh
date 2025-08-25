#!/bin/bash

# Streamlined Dotfiles Setup Script
# Simple, fast setup for essential tools and configurations

set -euo pipefail

echo "🚀 Setting up dotfiles..."

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Basic validation
if [[ ! -f "$DOTFILES_DIR/symlinks.yaml" ]]; then
    echo "❌ Not in dotfiles directory"
    exit 1
fi

cd "$DOTFILES_DIR"

# Install Homebrew if not present
if ! command -v brew >/dev/null 2>&1; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install essential packages
echo "📦 Installing packages..."
brew bundle install --file=scripts/installs/Brewfile

# Run dotbot for symlinks
echo "🔗 Creating symlinks..."
./install.sh --auto-yes

# Install git hooks (simple validation)
echo "🔧 Setting up git hooks..."
if [[ -f "scripts/install-git-hooks.sh" ]]; then
    ./scripts/install-git-hooks.sh
fi

# Set ZSH as default shell
if [[ "$SHELL" != */zsh ]]; then
    echo "🐚 Setting ZSH as default shell..."
    chsh -s "$(which zsh)"
fi

# Basic validation
echo "✅ Checking setup..."
if [[ -L "$HOME/.zshenv" ]]; then
    echo "✅ Shell configuration linked"
else
    echo "⚠️ Shell configuration may need attention"
fi

if command -v starship >/dev/null 2>&1; then
    echo "✅ Starship prompt installed"
else
    echo "⚠️ Starship not found"
fi

echo ""
echo "🎉 Dotfiles setup complete!"
echo ""
echo "Next steps:"
echo "• Restart your terminal"
echo "• Run 'source ~/.zshenv' to load environment"
echo "• Customize settings in ~/.config/"
echo ""
echo "Useful commands:"
echo "• 'backup-dotfiles' - Create backup"
echo "• 'update-dotfiles' - Pull latest changes"
echo ""

# Send notification
if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "Setup Complete" -message "Dotfiles are ready to use!"
fi