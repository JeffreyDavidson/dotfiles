#!/usr/bin/env zsh

function exists() {
  # `command -v` is similar to `which`
  # https://stackoverflow.com/a/677212/1341838
  command -v $1 >/dev/null 2>&1

  # More explicitly written:
  # command -v $1 1>/dev/null 2>/dev/null
}

echo "\n<<< Starting Homebrew Setup >>>\n"

if exists brew; then
  echo "brew exists, skipping install"
else
  echo "brew doesn't exist, continuing with install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# TODO: Keep an eye out for a different `--no-quarantine` solution.
# Currently, you can't do `brew bundle --no-quarantine` as an option.
# export HOMEBREW_CASK_OPTS="--no-quarantine"
# https://github.com/Homebrew/homebrew-bundle/issues/474

# HOMEBREW_CASK_OPTS is exported in `zshenv` with
# `--no-quarantine` and `--no-binaries` options,
# which makes them available to Homebrew for the
# first install (before our `zshrc` is sourced).

echo "Installing VS Code Extensions"
cat applications/vscode/extensions-list | xargs -L 1 code --install-extension
code --install-extension applications/vscode/extensions/Better\ Keybindings/Better-Keybindings-0.1.2.vsix
code --install-extension applications/vscode/extensions/Simple\ Project\ Switcher/Simple-Project-Switcher-0.1.4.vsix

echo "\n<<< Finished Homebrew Setup >>>\n"
