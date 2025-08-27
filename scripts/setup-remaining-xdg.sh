#!/bin/bash

# Remaining Applications XDG Migration Script
# Migrates additional applications to XDG-compliant locations where possible

set -euo pipefail

# Set XDG variables if not already set
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"

echo "🧹 Cleaning up remaining directories with XDG compliance..."

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

# 1. Composer - Split between config and data
if [[ -d "$HOME/.composer" ]]; then
    echo "📦 Composer configuration migration..."
    
    # Config files go to XDG_CONFIG_HOME
    COMPOSER_CONFIG="$XDG_CONFIG_HOME/composer"
    mkdir -p "$COMPOSER_CONFIG"
    
    # Copy config files only
    if [[ -f "$HOME/.composer/composer.json" ]]; then
        cp "$HOME/.composer/composer.json" "$COMPOSER_CONFIG/"
        echo "   ✓ Moved composer.json to config directory"
    fi
    if [[ -f "$HOME/.composer/config.json" ]]; then
        cp "$HOME/.composer/config.json" "$COMPOSER_CONFIG/"
        echo "   ✓ Moved config.json to config directory"
    fi
    if [[ -f "$HOME/.composer/auth.json" ]]; then
        cp "$HOME/.composer/auth.json" "$COMPOSER_CONFIG/"
        echo "   ✓ Moved auth.json to config directory"
    fi
    
    # Data files (vendor, cache) go to XDG_DATA_HOME
    COMPOSER_DATA="$XDG_DATA_HOME/composer"
    if [[ -d "$HOME/.composer/vendor" ]]; then
        mkdir -p "$COMPOSER_DATA"
        cp -r "$HOME/.composer/vendor" "$COMPOSER_DATA/"
        echo "   ✓ Moved vendor directory to data directory"
    fi
    
    echo "   ✅ Composer XDG setup complete"
    echo "   🗑️  You can now remove: rm -rf '$HOME/.composer'"
fi

# 2. FontConfig (if it exists and isn't already XDG)
if [[ -d "$HOME/.fontconfig" ]]; then
    migrate_directory "$HOME/.fontconfig" "$XDG_CONFIG_HOME/fontconfig" "FontConfig"
fi

# 3. Clean up backup and temporary files
echo ""
echo "🧹 Cleaning up backup and temporary files..."

if [[ -f "$HOME/.claude.json.backup" ]]; then
    echo "   🗑️  Removing Claude backup file"
    rm -f "$HOME/.claude.json.backup"
fi

if [[ -f "$HOME/.DS_Store" ]]; then
    echo "   🗑️  Removing .DS_Store (will be auto-recreated by macOS)"
    rm -f "$HOME/.DS_Store"
fi

# 4. Report on directories that cannot be easily moved
echo ""
echo "📋 Summary of remaining directories:"
echo ""
echo "   ✅ MOVED TO XDG:"
echo "      • ~/.composer → ~/.config/composer + ~/.local/share/composer"
echo "      • ~/.fontconfig → ~/.config/fontconfig (if existed)"
echo ""
echo "   ⚠️  CANNOT EASILY MOVE (application limitations):"
[[ -d "$HOME/.cursor" ]] && echo "      • ~/.cursor - Cursor AI editor (no XDG support yet)"
[[ -d "$HOME/.codeium" ]] && echo "      • ~/.codeium - Codeium AI assistant (no XDG support)"
[[ -d "$HOME/.gitkraken" ]] && echo "      • ~/.gitkraken - GitKraken client (no XDG support)"
[[ -d "$HOME/.warp" ]] && echo "      • ~/.warp - Warp terminal (no XDG support)"
[[ -d "$HOME/.vscode" ]] && echo "      • ~/.vscode - VS Code extensions (macOS specific location)"
echo ""
echo "   🔒 SHOULD NOT MOVE (tool-specific):"
[[ -d "$HOME/.n" ]] && echo "      • ~/.n - Node version manager (uses N_PREFIX)"
[[ -d "$HOME/.laravel-vapor" ]] && echo "      • ~/.laravel-vapor - Laravel Vapor CLI config"
[[ -d "$HOME/.expose" ]] && echo "      • ~/.expose - Expose tunnel configuration"
[[ -d "$HOME/.swiftpm" ]] && echo "      • ~/.swiftpm - Swift Package Manager"
[[ -d "$HOME/.gk" ]] && echo "      • ~/.gk - GitLens extension data"
echo ""
echo "✅ XDG migration complete for supported applications!"
echo "💡 The remaining directories are either tool-specific or don't support XDG yet."