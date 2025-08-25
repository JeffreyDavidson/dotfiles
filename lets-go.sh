#!/bin/bash

# Nord Color Variables
NORD_BLUE='\033[38;2;94;129;172m'      # #5E81AC - Primary accent
NORD_CYAN='\033[38;2;136;192;208m'     # #88C0D0 - Highlights  
NORD_GREEN='\033[38;2;163;190;140m'    # #A3BE8C - Success
NORD_WHITE='\033[38;2;236;239;244m'    # #ECEFF4 - Light text
NORD_GRAY='\033[38;2;76;86;106m'       # #4C566A - Secondary text
RESET='\033[0m'

# If not already set, specify dotfiles destination directory and source repo
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/jeffreyDavidson/dotfiles.git}"

# Print starting message
echo -e "${NORD_CYAN}JeffreyDavidson/Dotfiles Installation Script 🧰
${NORD_BLUE}This script will install or update specified dotfiles:
- From ${NORD_WHITE}${DOTFILES_REPO}${NORD_BLUE}
- Into ${NORD_WHITE}${DOTFILES_DIR}${NORD_BLUE}
Be sure you've read and understood what will be applied.${RESET}\n"

# If dependencies not met, install them
if ! hash git 2> /dev/null; then
  wget https://raw.githubusercontent.com/JeffreyDavidson/dotfiles/refs/heads/main/scripts/installs/prerequisites.sh
fi

# If dotfiles not yet present then clone
if [[ ! -d "$DOTFILES_DIR" ]]; then
  mkdir -p "${DOTFILES_DIR}" && \
  git clone --recursive ${DOTFILES_REPO} ${DOTFILES_DIR}
fi

# Execute setup or update script
cd "${DOTFILES_DIR}" && \
chmod +x ./install.sh && \
./install.sh --no-clear

# EOF
