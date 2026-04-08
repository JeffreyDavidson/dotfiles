# Laravel Herd Configuration
# This file contains all Laravel Herd-related environment variables and PATH configurations
# It's sourced from the main .zshrc to keep Herd config organized and separate

# Herd PHP binary paths
export PATH="$HOME/Library/Application Support/Herd/bin/:$PATH"

# Herd PHP version-specific configurations
export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"
export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"
export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"
export HERD_PHP_85_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/85/"

# Herd NVM configuration for Node.js management
export NVM_DIR="$HOME/Library/Application Support/Herd/config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm

# Source Herd's zsh configuration if available
[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

# Note: Homebrew PHP paths removed - using Herd's PHP instead
# The php symlink in Herd bin points to the version configured in Herd app

# Override php command to use herd php (respects per-project PHP version)
php() {
  command herd php "$@"
}

# Override node command to use herd node (respects per-project Node version)
node() {
  command herd node "$@"
}

# Helper function to get the correct npm/npx path based on Herd's isolated node version
_herd_node_bin() {
  local nvmrc_file
  local node_version

  # Check for .nvmrc in current directory or parents
  nvmrc_file=$(pwd)
  while [[ "$nvmrc_file" != "/" ]]; do
    if [[ -f "$nvmrc_file/.nvmrc" ]]; then
      node_version=$(cat "$nvmrc_file/.nvmrc" | tr -d 'v')
      break
    fi
    nvmrc_file=$(dirname "$nvmrc_file")
  done

  # If we found a version, look for matching Herd NVM installation
  if [[ -n "$node_version" ]]; then
    local herd_node_path="$NVM_DIR/versions/node"
    local matching_version=$(ls "$herd_node_path" 2>/dev/null | grep "v${node_version}" | sort -V | tail -1)
    if [[ -n "$matching_version" ]]; then
      echo "$herd_node_path/$matching_version/bin"
      return
    fi
  fi

  # Fallback to current nvm version
  echo "$(dirname "$(command which node)")"
}

# Override npm command to use the correct Node version's npm
npm() {
  local bin_path=$(_herd_node_bin)
  "$bin_path/npm" "$@"
}

# Override npx command to use the correct Node version's npx
npx() {
  local bin_path=$(_herd_node_bin)
  "$bin_path/npx" "$@"
}