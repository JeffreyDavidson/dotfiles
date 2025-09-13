#!/bin/bash

# SSH XDG Migration Script
# Safely migrates SSH configuration to XDG-compliant location

set -euo pipefail

# Set XDG variables if not already set
: "${XDG_CONFIG_HOME:=$HOME/.config}"

OLD_SSH_DIR="$HOME/.ssh"
NEW_SSH_DIR="$XDG_CONFIG_HOME/ssh"

echo "🔐 Setting up SSH with XDG compliance..."

# Check if SSH directory exists
if [[ ! -d "$OLD_SSH_DIR" ]]; then
    echo "ℹ️  No SSH configuration found in $OLD_SSH_DIR"
    echo "   SSH will use XDG location when first configured"
    mkdir -p "$NEW_SSH_DIR"
    chmod 700 "$NEW_SSH_DIR"
    echo "✅ XDG SSH directory created: $NEW_SSH_DIR"
    exit 0
fi

# Check if XDG SSH directory already exists
if [[ -d "$NEW_SSH_DIR" ]]; then
    echo "📁 XDG SSH directory already exists: $NEW_SSH_DIR"
    echo "⚠️  Both ~/.ssh and ~/.config/ssh exist!"
    echo "   Please manually review and merge configurations if needed."
    exit 0
fi

echo "📂 Migrating SSH configuration to XDG location..."

# Create the new directory with proper permissions
mkdir -p "$NEW_SSH_DIR"
chmod 700 "$NEW_SSH_DIR"

# Copy all SSH files preserving permissions
if cp -rp "$OLD_SSH_DIR"/* "$NEW_SSH_DIR/" 2>/dev/null; then
    echo "✅ SSH configuration migrated to: $NEW_SSH_DIR"
    
    # Update SSH config file to use XDG paths if it has absolute paths
    if [[ -f "$NEW_SSH_DIR/config" ]]; then
        # Create a backup
        cp "$NEW_SSH_DIR/config" "$NEW_SSH_DIR/config.backup"
        
        # Update any references to ~/.ssh in the config file
        sed -i.bak "s|$HOME/\.ssh|$NEW_SSH_DIR|g" "$NEW_SSH_DIR/config" 2>/dev/null || true
        rm -f "$NEW_SSH_DIR/config.bak" 2>/dev/null || true
        
        echo "   ✓ Updated SSH config file paths"
    fi
    
    echo ""
    echo "🗑️  You can now safely remove the old SSH directory:"
    echo "   rm -rf '$OLD_SSH_DIR'"
    echo ""
    echo "⚠️  IMPORTANT: Before removing ~/.ssh, verify that:"
    echo "   1. Your SSH keys work: ssh-add -l"
    echo "   2. Your SSH connections work with the new config"
    echo "   3. Any applications using SSH (Git, rsync, etc.) still work"
    echo ""
    echo "📝 SSH_CONFIG_FILE is already set in your .zshenv to use the XDG location"
    
else
    echo "❌ Failed to migrate SSH configuration"
    rm -rf "$NEW_SSH_DIR" 2>/dev/null || true
    exit 1
fi