#!/bin/bash

# Development Tools XDG Migration Script
# Safely migrates npm and other dev tools to XDG locations

set -euo pipefail

# Set XDG variables if not already set
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"

echo "🛠️  Setting up development tools with XDG compliance..."

# Function to migrate a directory safely
migrate_directory() {
    local old_dir="$1"
    local new_dir="$2" 
    local tool_name="$3"
    
    if [[ ! -d "$old_dir" ]]; then
        echo "   ℹ️  No $tool_name configuration found in $old_dir"
        return 0
    fi
    
    if [[ -d "$new_dir" ]]; then
        echo "   📁 XDG $tool_name directory already exists: $new_dir"
        return 0
    fi
    
    echo "   📂 Migrating $tool_name configuration to XDG location..."
    mkdir -p "$(dirname "$new_dir")"
    
    if cp -r "$old_dir" "$new_dir"; then
        echo "   ✓ $tool_name migrated to: $new_dir"
        echo "   🗑️  You can now safely remove: rm -rf '$old_dir'"
    else
        echo "   ❌ Failed to migrate $tool_name configuration"
        return 1
    fi
}

# NPM Cache (only move cache, not the global config)
if [[ -d "$HOME/.npm" ]]; then
    NPM_CACHE="$XDG_CACHE_HOME/npm"
    migrate_directory "$HOME/.npm" "$NPM_CACHE" "npm cache"
fi

# FontConfig (usually already XDG compliant but sometimes creates ~/.fontconfig)
FONTCONFIG_OLD="$HOME/.fontconfig"
FONTCONFIG_NEW="$XDG_CONFIG_HOME/fontconfig"
if [[ -d "$FONTCONFIG_OLD" ]]; then
    migrate_directory "$FONTCONFIG_OLD" "$FONTCONFIG_NEW" "FontConfig"
fi

# Additional tools that might benefit from XDG
echo ""
echo "🔍 Checking for other development tools..."

# VS Code (on Linux, already uses XDG by default)
if [[ -d "$HOME/.vscode" ]] && [[ "$(uname)" == "Linux" ]]; then
    VSCODE_OLD="$HOME/.vscode"
    VSCODE_NEW="$XDG_CONFIG_HOME/Code"
    migrate_directory "$VSCODE_OLD" "$VSCODE_NEW" "VS Code"
fi

echo ""
echo "✅ Development tools XDG migration complete!"
echo ""
echo "📝 Summary of environment variables set:"
echo "   NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm"
echo ""
echo "🔄 Restart your terminal to apply the new environment variables."