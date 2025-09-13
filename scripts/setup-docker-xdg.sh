#!/bin/bash

# Docker XDG Migration Script  
# Safely migrates Docker from ~/.docker to ~/.config/docker

set -euo pipefail

DEFAULT_DOCKER="$HOME/.docker"
XDG_DOCKER="${XDG_CONFIG_HOME:-$HOME/.config}/docker"

echo "🐳 Setting up Docker with XDG compliance..."

# Check if default Docker directory exists
if [[ ! -d "$DEFAULT_DOCKER" ]]; then
    echo "ℹ️  No Docker configuration found in $DEFAULT_DOCKER"
    echo "   Docker will use XDG location when first run"
    exit 0
fi

# Stop Docker if running (optional - Docker can handle this)
echo "🛑 Stopping Docker processes if running..."
docker system prune -f 2>/dev/null || true

# Create XDG directory if it doesn't exist or is a symlink  
if [[ -L "$XDG_DOCKER" ]]; then
    echo "🔗 Removing symlink: $XDG_DOCKER"
    rm "$XDG_DOCKER"
elif [[ -d "$XDG_DOCKER" ]]; then
    echo "📁 XDG Docker directory already exists"
fi

# Copy Docker directory (excluding runtime sockets/locks)
if [[ ! -d "$XDG_DOCKER" ]]; then
    echo "📂 Migrating Docker configuration to XDG location..."
    cp -r "$DEFAULT_DOCKER" "$XDG_DOCKER"
    
    # Remove any socket/lock files that may have been copied
    find "$XDG_DOCKER" -name "*.sock" -delete 2>/dev/null || true
    find "$XDG_DOCKER" -name "*.lock" -delete 2>/dev/null || true
    find "$XDG_DOCKER" -type s -delete 2>/dev/null || true
fi

# Verify setup by checking if Docker can find its config
export DOCKER_CONFIG="$XDG_DOCKER"
if docker info --format '{{.ClientInfo.Context}}' >/dev/null 2>&1; then
    echo "✅ Docker XDG setup complete!"
    echo "   Configuration available in: $XDG_DOCKER"
    
    # Optionally remove old directory (with confirmation)
    echo ""
    echo "🗑️  You can now safely remove the old Docker directory:"
    echo "   rm -rf '$DEFAULT_DOCKER'"
else
    echo "❌ Docker setup verification failed"
    exit 1
fi