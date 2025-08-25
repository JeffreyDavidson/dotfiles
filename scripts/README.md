# Scripts Directory

This directory contains all installation and setup scripts for the dotfiles.

## Main Scripts

- **`setup.sh`** - Streamlined setup script for essential tools and configurations
- **`backup.sh`** - Creates backups of your dotfiles repository  
- **`install-git-hooks.sh`** - Installs Git hooks for validation and security
- **`setup-gpg-xdg.sh`** - Migrates GPG setup to XDG-compliant directory

## Subdirectories

### `installs/`
- **`Brewfile`** - Homebrew package definitions
- **`prerequisites.sh`** - Core dependency installation

### `macos-setup/`
- **`macos-preferences.sh`** - System preference configuration
- **`macos-apps.sh`** - Application-specific settings

### `setup/`  
- **`setup_node.zsh`** - Node.js and npm setup
- **`setup_ssh.zsh`** - SSH key generation and configuration
- **`setup_vscode.zsh`** - VS Code extensions and settings

## Usage

Most scripts are designed to be run as part of the main installation process, but can also be executed individually for targeted setup or maintenance.

```bash
# Main installation
./scripts/setup.sh

# Individual components  
./scripts/setup/setup_node.zsh
./scripts/backup.sh
```