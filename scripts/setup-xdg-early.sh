#!/bin/bash

# Early XDG Directory Setup Script
# Creates XDG-compliant directories before applications can create them in ~/
# This prevents ~/.docker, ~/.gnupg, and other directories from being created

set -euo pipefail

# Set XDG variables if not already set
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

echo "🏗️  Setting up early XDG directories..."

# Create base XDG directories
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_STATE_HOME"

# Pre-create application-specific directories to prevent ~/. creation
echo "📁 Creating application directories in XDG locations..."

# Docker
DOCKER_CONFIG_DIR="$XDG_CONFIG_HOME/docker"
mkdir -p "$DOCKER_CONFIG_DIR"
chmod 700 "$DOCKER_CONFIG_DIR"
echo "   ✓ Docker config: $DOCKER_CONFIG_DIR"

# GPG
GNUPG_HOME="$XDG_CONFIG_HOME/gnupg"
mkdir -p "$GNUPG_HOME"
chmod 700 "$GNUPG_HOME"
echo "   ✓ GPG home: $GNUPG_HOME"

# Development tools
NPM_CACHE_DIR="$XDG_CACHE_HOME/npm"
JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
IPYTHON_CONFIG_DIR="$XDG_CONFIG_HOME/ipython"
FONTCONFIG_DIR="$XDG_CONFIG_HOME/fontconfig"

mkdir -p "$NPM_CACHE_DIR"
mkdir -p "$JUPYTER_CONFIG_DIR" 
mkdir -p "$IPYTHON_CONFIG_DIR"
mkdir -p "$FONTCONFIG_DIR"
echo "   ✓ Development tools: npm, jupyter, ipython, fontconfig"

# Other common XDG applications
mkdir -p "$XDG_DATA_HOME/zsh"
mkdir -p "$XDG_STATE_HOME/zsh"
mkdir -p "$XDG_CACHE_HOME/zsh/antigen"
mkdir -p "$XDG_STATE_HOME/less"
mkdir -p "$XDG_DATA_HOME/z"
mkdir -p "$XDG_DATA_HOME/zoxide"

echo "✅ Early XDG setup complete!"
echo "   Applications will now use XDG-compliant directories"