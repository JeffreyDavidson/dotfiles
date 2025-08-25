#!/bin/bash

# Simple Dotfiles Backup Script
# Creates a backup of your dotfiles repository

set -euo pipefail

# Configuration
BACKUP_DIR="$HOME/Backups/dotfiles-$(date +%Y%m%d_%H%M%S)"
DOTFILES_DIR="${DOTFILES:-$HOME/Projects/dotfiles}"

echo "🔄 Backing up dotfiles..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if dotfiles directory exists
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "❌ Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Create git bundle (complete repository backup)
echo "📦 Creating git bundle..."
git bundle create "$BACKUP_DIR/dotfiles.bundle" --all

# Copy working directory
echo "📁 Copying files..."
cp -R "$DOTFILES_DIR" "$BACKUP_DIR/dotfiles-working"

# Create simple info file
cat > "$BACKUP_DIR/backup-info.txt" <<EOF
Dotfiles Backup
===============
Date: $(date)
System: $(uname -a)
Git Status:
$(git status --porcelain || echo "No git status available")

Recent Commits:
$(git log --oneline -5 || echo "No git log available")
EOF

# Compress backup
echo "🗜️ Compressing backup..."
cd "$HOME/Backups"
tar -czf "$(basename "$BACKUP_DIR").tar.gz" "$(basename "$BACKUP_DIR")"
rm -rf "$BACKUP_DIR"

# Clean old backups (keep last 5)
ls -t dotfiles-*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true

echo "✅ Backup complete: $HOME/Backups/$(basename "$BACKUP_DIR").tar.gz"

# Send notification (macOS)
if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "Backup Complete" -message "Dotfiles backed up successfully"
fi