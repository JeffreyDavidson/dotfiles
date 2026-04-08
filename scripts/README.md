# Scripts Directory

This directory contains all installation and setup scripts for the dotfiles.

## Main Scripts

- **`setup.sh`** - Streamlined setup script for essential tools and configurations
- **`backup.sh`** - Creates backups of your dotfiles repository
- **`setup-gpg-xdg.sh`** - Migrates GPG setup to XDG-compliant directory
- **`setup-xdg-early.sh`** - Pre-creates XDG directories before applications can pollute home
- **`setup-ssh-xdg.sh`** - Migrates SSH configuration to XDG location
- **`setup-docker-xdg.sh`** - Migrates Docker configuration to XDG location
- **`setup-dev-tools-xdg.sh`** - Migrates dev tools (NPM, FontConfig, VS Code) to XDG locations
- **`setup-remaining-xdg.sh`** - Handles remaining XDG cleanup and documents unmovable directories

## Subdirectories

### `installs/`
- **`Brewfile`** - Homebrew package definitions
- **`prerequisites.sh`** - Core dependency installation

### `macos-setup/`
- **`macos-preferences.sh`** - System preference configuration
- **`macos-apps.sh`** - Application-specific settings

### `setup/`
- **`setup_vscode.zsh`** - VS Code custom extensions installation

## Usage

Most scripts are designed to be run as part of the main installation process, but can also be executed individually for targeted setup or maintenance.

```bash
# Main installation
./scripts/setup.sh

# Individual components
./scripts/backup.sh
```
