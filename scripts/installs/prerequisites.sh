#!/usr/bin/env bash

# Prerequisite Installation Script (macOS)
# Installs core packages needed before dotfiles setup

set -euo pipefail

core_packages=('git' 'vim' 'zsh')

# Nord Colors
NORD_BLUE='\033[38;2;94;129;172m'
NORD_GREEN='\033[38;2;163;190;140m'
NORD_YELLOW='\033[38;2;235;203;139m'
RESET='\033[0m'

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo -e "${NORD_YELLOW}This script only supports macOS.${RESET}"
  exit 1
fi

echo -e "${NORD_BLUE}Prerequisite Installation${RESET}"
echo -e "Installs core packages needed for dotfiles setup: ${core_packages[*]}"
echo ""

# Help
if [[ "${*}" == *"--help"* ]]; then exit 0; fi

# Confirm
if [[ "${*}" != *"--auto-yes"* ]]; then
  echo -e "${NORD_BLUE}Continue? (y/N)${RESET}"
  read -t 15 -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${NORD_YELLOW}Cancelled.${RESET}"
    exit 0
  fi
fi

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  echo -e "${NORD_BLUE}Installing Homebrew...${RESET}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH=/opt/homebrew/bin:$PATH
fi

# Install packages
for app in "${core_packages[@]}"; do
  if command -v "$app" >/dev/null 2>&1; then
    echo -e "  ${NORD_GREEN}✓ $app${RESET} (already installed)"
  else
    echo -e "  ${NORD_BLUE}Installing $app...${RESET}"
    brew install "$app"
  fi
done

echo -e "\n${NORD_GREEN}Prerequisites installed.${RESET}"
