#!/bin/bash

# GPG XDG Migration Script
# Safely migrates GPG from ~/.gnupg to ~/.config/gnupg

set -euo pipefail

DEFAULT_GPG="$HOME/.gnupg"
XDG_GPG="${XDG_CONFIG_HOME:-$HOME/.config}/gnupg"

echo "🔐 Setting up GPG with XDG compliance..."

# Check if default GPG directory exists
if [[ ! -d "$DEFAULT_GPG" ]]; then
    echo "⚠️  No GPG keys found in $DEFAULT_GPG"
    echo "   Generate keys first: gpg --gen-key"
    exit 0
fi

# Stop any running GPG agents
echo "🛑 Stopping GPG agents..."
gpgconf --kill all 2>/dev/null || true
sleep 2

# Create XDG directory if it doesn't exist or is a symlink
if [[ -L "$XDG_GPG" ]]; then
    echo "🔗 Removing symlink: $XDG_GPG"
    rm "$XDG_GPG"
elif [[ -d "$XDG_GPG" ]]; then
    echo "📁 XDG GPG directory already exists"
fi

# Copy GPG directory (excluding sockets)
if [[ ! -d "$XDG_GPG" ]]; then
    echo "📂 Migrating GPG directory to XDG location..."
    cp -r "$DEFAULT_GPG" "$XDG_GPG"
    chmod 700 "$XDG_GPG"
    
    # Remove any socket files that may have been copied
    find "$XDG_GPG" -type s -delete 2>/dev/null || true
fi

# Verify setup
if gpg --list-secret-keys >/dev/null 2>&1; then
    echo "✅ GPG XDG setup complete!"
    echo "   Keys available in: $XDG_GPG"
else
    echo "❌ GPG setup verification failed"
    exit 1
fi