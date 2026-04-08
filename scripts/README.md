# Scripts Directory

This directory contains all installation and setup scripts for the dotfiles.

## Main Scripts

- **`backup.sh`** - Creates backups of your dotfiles repository
- **`setup-xdg-early.sh`** - Pre-creates XDG directories before applications can pollute home
- **`migrate-xdg.sh`** - Migrates GPG, SSH, npm, Composer, and FontConfig to XDG locations

## Subdirectories

### `installs/`
- **`Brewfile`** - Homebrew package definitions
- **`prerequisites.sh`** - Core dependency installation (macOS/Homebrew)

### `macos-setup/`
- **`macos-preferences.sh`** - System preference configuration
- **`macos-apps.sh`** - Application-specific settings

## Usage

Most scripts are run as part of the main installation process (`./install.sh`), but can also be executed individually:

```bash
# Full installation
./install.sh

# Individual components
./scripts/backup.sh
./scripts/migrate-xdg.sh
```
