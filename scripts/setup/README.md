# Setup Scripts

This directory contains specialized setup scripts for individual tools and services.

## Scripts

- **`setup_node.zsh`** - Node.js and npm configuration setup
- **`setup_ssh.zsh`** - SSH key generation and configuration  
- **`setup_vscode.zsh`** - VS Code settings and extensions installation

## Usage

These scripts are typically called by the main installation script or can be run individually for specific tool setup.

```bash
# Run individual setup scripts
./scripts/setup/setup_node.zsh
./scripts/setup/setup_ssh.zsh  
./scripts/setup/setup_vscode.zsh
```

## Note

These scripts complement the main `install.sh` and are designed to be idempotent (safe to run multiple times).