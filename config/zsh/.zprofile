# Dynamic Homebrew path detection for cross-platform support
if command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif command -v /usr/local/bin/brew >/dev/null 2>&1; then
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
fi
