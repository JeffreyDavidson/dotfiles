# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

The following commands are available for development and setup:

- **Install dotfiles:** `./install.sh` - Full interactive setup with symlinks, package installation, and system configuration
- **Install dotfiles (auto-yes):** `./install.sh --auto-yes` - Non-interactive installation
- **Quick install:** `./lets-go.sh` - Simplified installation script
- **Make install:** `make install` - Alternative way to run the install script

## Architecture Overview

This is Jeffrey Davidson's personal dotfiles repository organized with the following structure:

### Core Components

- **Dotbot Integration:** Uses dotbot (in `lib/dotbot/`) for automated symlinking and configuration management
- **Configuration Management:** Primary configuration lives in `symlinks.yaml` which defines dotbot symlink mappings
- **Installation System:** Multi-stage installation process (pre-setup, dotfiles, packages, preferences, finishing)

### Key Directories

- `config/` - Core application configurations (zsh, nvim, git, starship, bat)
- `applications/` - Application-specific settings (VS Code, iTerm, Warp terminal)
- `scripts/` - Installation and setup scripts
  - `installs/` - Contains Brewfile and prerequisite installation scripts
  - `macos-setup/` - macOS-specific preference and app configuration scripts
- `utils/` - Utility scripts (color-map, weather, welcome banner)
- `steps/` - Modular configuration steps (node.yml, vscode.yml, warp.yml)

### Environment Configuration

- **XDG Base Directory:** Follows XDG specification with variables set in `config/zsh/.zshenv`
- **ZSH Setup:** Primary shell configuration with Antigen plugin management
- **Cross-Platform:** Primarily macOS-focused but includes some Linux support

### Development Workflow

The dotfiles use a modular approach where:
1. `symlinks.yaml` defines the core symlink mappings using dotbot
2. Individual YAML files in `steps/` handle specific application setups
3. Shell scripts handle system-level configuration and package installation
4. Environment variables are centralized in `.zshenv` following XDG standards

The installation process is designed to be idempotent and can be run multiple times safely.

## Git Commit Guidelines

When working with this repository, follow these commit standards:

- **Never include Claude attribution** - Do not add "🤖 Generated with [Claude Code]", "Co-Authored-By: Claude", or similar Claude-related attribution to commit messages
- **All commits must be signed** - Use GPG signing for security and authenticity. If GPG keys are not set up, use `--no-gpg-sign` temporarily but ensure proper GPG configuration is completed