#!/bin/bash

# If not already set, specify dotfiles destination directory and source repo
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Projects/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/jeffreyDavidson/dotfiles.git}"

# Print starting message
echo -e "\033[1;35m""JeffreyDavidson/Dotfiles Installation Script 🧰
\033[0;35mThis script will install or update specified dotfiles:
- From \033[4;35m${DOTFILES_REPO}\033[0;35m
- Into \033[4;35m${DOTFILES_DIR}\033[0;35m
Be sure you've read and understood the what will be applied.\033[0m\n"

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
