#!/bin/bash

# XDG Migration Script
# Migrates GPG, SSH, npm, Composer, and FontConfig to XDG-compliant locations
# Safe to run multiple times — skips already-migrated items

set -euo pipefail

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

echo "Migrating directories to XDG-compliant locations..."
echo ""

# Helper: migrate a directory if old exists and new doesn't
migrate_directory() {
    local old_dir="$1"
    local new_dir="$2"
    local name="$3"

    if [[ ! -d "$old_dir" ]]; then
        return 0
    fi

    if [[ -d "$new_dir" ]]; then
        echo "  [skip] $name — already exists at $new_dir"
        return 0
    fi

    echo "  [migrate] $name: $old_dir -> $new_dir"
    mkdir -p "$(dirname "$new_dir")"
    cp -rp "$old_dir" "$new_dir"
    echo "           Done. You can remove: rm -rf '$old_dir'"
}

# --- GPG ---
echo "GPG:"
OLD_GPG="$HOME/.gnupg"
NEW_GPG="$XDG_CONFIG_HOME/gnupg"

if [[ -d "$OLD_GPG" ]] && [[ ! -d "$NEW_GPG" ]]; then
    gpgconf --kill all 2>/dev/null || true
    sleep 1
    # Remove symlink if present
    [[ -L "$NEW_GPG" ]] && rm "$NEW_GPG"
    cp -r "$OLD_GPG" "$NEW_GPG"
    chmod 700 "$NEW_GPG"
    find "$NEW_GPG" -type s -delete 2>/dev/null || true
    echo "  [migrate] GPG: $OLD_GPG -> $NEW_GPG"
    echo "           Done. Verify with: gpg --list-secret-keys"
    echo "           Then remove: rm -rf '$OLD_GPG'"
elif [[ -d "$NEW_GPG" ]]; then
    echo "  [skip] GPG — already at $NEW_GPG"
else
    echo "  [skip] GPG — no keys found in $OLD_GPG"
fi

# --- SSH ---
echo ""
echo "SSH:"
OLD_SSH="$HOME/.ssh"
NEW_SSH="$XDG_CONFIG_HOME/ssh"

if [[ -d "$OLD_SSH" ]] && [[ ! -d "$NEW_SSH" ]]; then
    mkdir -p "$NEW_SSH"
    chmod 700 "$NEW_SSH"
    cp -rp "$OLD_SSH"/* "$NEW_SSH/" 2>/dev/null || true

    # Update paths in SSH config
    if [[ -f "$NEW_SSH/config" ]]; then
        sed -i.bak "s|$HOME/\.ssh|$NEW_SSH|g" "$NEW_SSH/config" 2>/dev/null || true
        rm -f "$NEW_SSH/config.bak"
    fi

    echo "  [migrate] SSH: $OLD_SSH -> $NEW_SSH"
    echo "           Verify: ssh-add -l"
    echo "           Then remove: rm -rf '$OLD_SSH'"
elif [[ -d "$NEW_SSH" ]]; then
    echo "  [skip] SSH — already at $NEW_SSH"
else
    echo "  [skip] SSH — no config found"
fi

# --- npm ---
echo ""
echo "npm:"
migrate_directory "$HOME/.npm" "$XDG_CACHE_HOME/npm" "npm cache"

# --- FontConfig ---
echo ""
echo "FontConfig:"
migrate_directory "$HOME/.fontconfig" "$XDG_CONFIG_HOME/fontconfig" "FontConfig"

# --- Composer ---
echo ""
echo "Composer:"
OLD_COMPOSER="$HOME/.composer"
COMPOSER_CONFIG="$XDG_CONFIG_HOME/composer"
COMPOSER_DATA="$XDG_DATA_HOME/composer"

if [[ -d "$OLD_COMPOSER" ]] && [[ ! -d "$COMPOSER_CONFIG" ]]; then
    mkdir -p "$COMPOSER_CONFIG"
    mkdir -p "$COMPOSER_DATA"

    for f in composer.json config.json auth.json; do
        [[ -f "$OLD_COMPOSER/$f" ]] && cp "$OLD_COMPOSER/$f" "$COMPOSER_CONFIG/"
    done

    [[ -d "$OLD_COMPOSER/vendor" ]] && cp -r "$OLD_COMPOSER/vendor" "$COMPOSER_DATA/"

    echo "  [migrate] Composer: $OLD_COMPOSER -> $COMPOSER_CONFIG + $COMPOSER_DATA"
    echo "           Then remove: rm -rf '$OLD_COMPOSER'"
elif [[ -d "$COMPOSER_CONFIG" ]]; then
    echo "  [skip] Composer — already at $COMPOSER_CONFIG"
else
    echo "  [skip] Composer — not found"
fi

# --- Cleanup stale files ---
echo ""
echo "Cleanup:"
[[ -f "$HOME/.claude.json.backup" ]] && rm -f "$HOME/.claude.json.backup" && echo "  [remove] .claude.json.backup"
[[ -f "$HOME/.DS_Store" ]] && rm -f "$HOME/.DS_Store" && echo "  [remove] .DS_Store"

# --- Summary ---
echo ""
echo "XDG migration complete."
echo ""
echo "Directories that cannot be moved (no XDG support):"
[[ -d "$HOME/.codeium" ]] && echo "  - ~/.codeium (Codeium)"
[[ -d "$HOME/.gitkraken" ]] && echo "  - ~/.gitkraken (GitKraken)"
[[ -d "$HOME/.vscode" ]] && echo "  - ~/.vscode (VS Code extensions)"
[[ -d "$HOME/.n" ]] && echo "  - ~/.n (Node version manager)"
[[ -d "$HOME/.laravel-vapor" ]] && echo "  - ~/.laravel-vapor (Laravel Vapor)"
[[ -d "$HOME/.expose" ]] && echo "  - ~/.expose (Expose)"
echo ""
