# GPG Configuration

This directory contains GPG configuration files but **not** the actual keys or personal crypto data.

## What's Included
- `gpg.conf` - GPG security settings and preferences
- `gpg-agent.conf` - GPG agent configuration  
- `common.conf` - Common GPG settings

## What's Excluded (Machine-Specific)
- Private keys (`private-keys-v1.d/`)
- Public keyring (`pubring.kbx`, `public-keys.d/`)
- Trust database (`trustdb.gpg`) 
- Revocation certificates (`openpgp-revocs.d/`)

## Setup
The installation script will automatically migrate your existing GPG setup to use XDG Base Directory compliance while preserving your keys and personal data.

Run: `./scripts/setup-gpg-xdg.sh` to migrate from `~/.gnupg` to `~/.config/gnupg`