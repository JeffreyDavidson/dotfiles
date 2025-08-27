# Laravel Herd Configuration
# This file contains all Laravel Herd-related environment variables and PATH configurations
# It's sourced from the main .zshrc to keep Herd config organized and separate

# Herd PHP binary paths
export PATH="/Users/jeffreydavidson/Library/Application Support/Herd/bin/:$PATH"

# Herd PHP version-specific configurations
export HERD_PHP_83_INI_SCAN_DIR="/Users/jeffreydavidson/Library/Application Support/Herd/config/php/83/"
export HERD_PHP_84_INI_SCAN_DIR="/Users/jeffreydavidson/Library/Application Support/Herd/config/php/84/"
export HERD_PHP_85_INI_SCAN_DIR="/Users/jeffreydavidson/Library/Application Support/Herd/config/php/85/"

# Herd NVM configuration for Node.js management
export NVM_DIR="/Users/jeffreydavidson/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm

# Source Herd's zsh configuration if available
[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

# Additional PHP paths (Homebrew installations used alongside Herd)
export PATH="/usr/local/opt/php@8.3/bin:$PATH"
export PATH="/usr/local/opt/php@8.3/sbin:$PATH"
export PATH="/usr/local/opt/php@8.4/bin:$PATH"
export PATH="/usr/local/opt/php@8.4/sbin:$PATH"