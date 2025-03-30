#!/usr/bin/env zsh

echo "\n<<< Starting Visual Studio Code Setup >>>\n"

echo "Installing VS Code Extensions"
code --install-extension applications/vscode/extensions/Better\ Keybindings/Better-Keybindings-0.1.2.vsix
code --install-extension applications/vscode/extensions/Simple\ Project\ Switcher/Simple-Project-Switcher-0.1.4.vsix

echo "\n<<< Finished Visual Studio Code Setup >>>\n"
