#!/usr/bin/env bash

# =============================================================================
# JeffreyDavidson/Dotfiles Installation Script
# =============================================================================
# Supports macOS with multi-phase installation
# Usage: ./install.sh [--auto-yes] [--no-clear] [--help]
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="JeffreyDavidson/dotfiles"
DOTFILES_REPO="https://github.com/${REPO_NAME}.git"

DOTBOT_CONFIG="symlinks.yaml"
DOTBOT_DIR="lib/dotbot"
DOTBOT_BIN="bin/dotbot"

BREWFILE_PATH="${DOTFILES_DIR}/scripts/installs/Brewfile"
LAUNCHPAD_LAYOUT_PATH="${DOTFILES_DIR}/config/macos/launchpad.yml"
MACOS_SETTINGS_DIR="${DOTFILES_DIR}/scripts/macos-setup"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
PREREQUISITE_URL="https://raw.githubusercontent.com/${REPO_NAME}/refs/heads/main/scripts/installs/prerequisites.sh"

PROMPT_TIMEOUT=15
AUTO_YES=false
START_TIME=$(date +%s)

# Nord Colors
NORD_BLUE='\033[38;2;94;129;172m'
NORD_CYAN='\033[38;2;136;192;208m'
NORD_GREEN='\033[38;2;163;190;140m'
NORD_YELLOW='\033[38;2;235;203;139m'
NORD_RED='\033[38;2;191;97;106m'
NORD_WHITE='\033[38;2;236;239;244m'
NORD_GRAY='\033[38;2;76;86;106m'
RESET='\033[0m'

# =============================================================================
# UTILITIES
# =============================================================================

make_banner() {
  local text="$1" color="${2:-$NORD_CYAN}" padding="${3:-0}"
  local len=$((${#text} + 2 + padding))
  local line=""
  for ((i = 0; i < len; i++)); do line="${line}─"; done
  echo -e "\n${color}╭${line}╮\n│ ${NORD_WHITE}${text}${color} │\n╰${line}╯\n${RESET}"
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

die() {
  echo -e "${NORD_RED}Error: $1${RESET}"
  exit 1
}

prompt_user() {
  local message="$1" default="${2:-N}"

  if [[ $AUTO_YES == true ]]; then
    echo "$default"
    return 0
  fi

  local prompt="${NORD_CYAN}$message${RESET}"
  if [[ "$default" == [Yy] ]]; then
    prompt="$prompt ${NORD_GRAY}[Y/n]${RESET}"
  else
    prompt="$prompt ${NORD_GRAY}[y/N]${RESET}"
  fi

  echo -e "$prompt" >/dev/tty
  local response
  read -t "$PROMPT_TIMEOUT" -n 1 -r response </dev/tty || true
  echo >/dev/tty

  echo "${response:-$default}"
}

is_yes() { [[ "$1" =~ ^[Yy]$ ]]; }

# =============================================================================
# PHASE 1: PRE-SETUP
# =============================================================================

pre_setup_tasks() {
  make_banner "JeffreyDavidson/Dotfiles Setup" "$NORD_CYAN" 1

  echo -e "${NORD_CYAN}This script will:${RESET}"
  echo -e "${NORD_GRAY}  1. Validate requirements and configure XDG directories${RESET}"
  echo -e "${NORD_GRAY}  2. Create symlinks via dotbot${RESET}"
  echo -e "${NORD_GRAY}  3. Install/update packages via Homebrew${RESET}"
  echo -e "${NORD_GRAY}  4. Configure shell, plugins, and system preferences${RESET}"
  echo -e "${NORD_GRAY}  5. Refresh environment and show summary${RESET}"
  echo ""

  # Check requirements
  for cmd in git curl; do
    if command_exists "$cmd"; then
      echo -e "  ${NORD_GREEN}✓ $cmd${RESET}"
    else
      if [[ "$cmd" == "git" ]]; then
        echo -e "  ${NORD_YELLOW}⚠ git not found, installing prerequisites...${RESET}"
        bash <(curl -s -L "$PREREQUISITE_URL") "$@" || die "Failed to install prerequisites"
        command_exists git || die "Git installation failed"
      else
        die "Required command not found: $cmd"
      fi
    fi
  done

  # Configure XDG variables
  export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
  export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
  export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
  export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

  # Create early XDG directories
  if [[ -f "./scripts/setup-xdg-early.sh" ]]; then
    chmod +x "./scripts/setup-xdg-early.sh" && "./scripts/setup-xdg-early.sh" || true
  fi

  echo -e "${NORD_GREEN}✓ Pre-setup complete${RESET}"

  # Confirm to proceed
  local response
  response=$(prompt_user "Ready to begin installation?" "N")
  if ! is_yes "$response"; then
    echo -e "\n${NORD_BLUE}Installation cancelled.${RESET}"
    exit 0
  fi
}

# =============================================================================
# PHASE 2: DOTFILES SETUP
# =============================================================================

setup_dotfiles() {
  make_banner "Setting up dotfiles" "$NORD_CYAN"

  cd "${DOTFILES_DIR}" || die "Failed to cd to $DOTFILES_DIR"

  # Update repo if it's a git repo
  if [[ -d ".git" ]]; then
    echo -e "${NORD_BLUE}Updating dotfiles repository...${RESET}"
    git pull origin main || echo -e "${NORD_YELLOW}⚠ Failed to pull latest changes, continuing${RESET}"

    echo -e "${NORD_BLUE}Updating submodules...${RESET}"
    git submodule update --recursive --remote --init || echo -e "${NORD_YELLOW}⚠ Failed to update submodules${RESET}"
  fi

  # Run dotbot for symlinks
  echo -e "${NORD_BLUE}Creating symlinks...${RESET}"
  local dotbot_path="${DOTBOT_DIR}/${DOTBOT_BIN}"

  git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive 2>/dev/null || true
  git submodule update --init --recursive "${DOTBOT_DIR}" || die "Failed to update dotbot"

  chmod +x "$dotbot_path"
  "${DOTFILES_DIR}/${dotbot_path}" -d "${DOTFILES_DIR}" -c "${DOTBOT_CONFIG}" || die "Dotbot symlink creation failed"

  echo -e "${NORD_GREEN}✓ Symlinks created${RESET}"
}

# =============================================================================
# PHASE 3: PACKAGE MANAGEMENT
# =============================================================================

install_packages() {
  make_banner "Package Management" "$NORD_CYAN"

  local response
  response=$(prompt_user "Install and update system packages?" "Y")
  if ! is_yes "$response"; then
    echo -e "${NORD_BLUE}Skipping package installation${RESET}"
    return 0
  fi

  # Install Homebrew if needed
  if ! command_exists brew; then
    echo -e "${NORD_BLUE}Installing Homebrew...${RESET}"
    /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)"

    # Add to PATH
    for brew_path in /opt/homebrew/bin /usr/local/bin; do
      if [[ -d "$brew_path" ]] && [[ ":$PATH:" != *":$brew_path:"* ]]; then
        export PATH="$brew_path:$PATH"
      fi
    done

    command_exists brew || die "Homebrew installation failed"
    echo -e "${NORD_GREEN}✓ Homebrew installed${RESET}"
  fi

  # Update and install packages
  if [[ -f "$BREWFILE_PATH" ]]; then
    echo -e "${NORD_BLUE}Updating Homebrew and installing packages...${RESET}"
    brew update
    brew upgrade
    brew bundle --file "$BREWFILE_PATH"
    brew cleanup
    echo -e "${NORD_GREEN}✓ Packages installed${RESET}"
  else
    echo -e "${NORD_YELLOW}⚠ Brewfile not found at $BREWFILE_PATH${RESET}"
  fi

  # Restore launchpad layout
  if command_exists lporg && [[ -f "$LAUNCHPAD_LAYOUT_PATH" ]]; then
    response=$(prompt_user "Restore launchpad layout?" "N")
    if is_yes "$response"; then
      lporg load --config="$LAUNCHPAD_LAYOUT_PATH" --yes --no-backup
      echo -e "${NORD_GREEN}✓ Launchpad layout restored${RESET}"
    fi
  fi

  # Check for macOS updates
  response=$(prompt_user "Check for macOS system updates?" "N")
  if is_yes "$response"; then
    local pending
    pending=$(softwareupdate -l 2>&1)
    if [[ "$pending" != *"No new software available."* ]]; then
      echo -e "${NORD_BLUE}Updates available${RESET}"
      response=$(prompt_user "Install macOS updates?" "N")
      if is_yes "$response"; then
        softwareupdate -i -a
      fi
    else
      echo -e "${NORD_GREEN}✓ macOS is up to date ($(sw_vers -productVersion))${RESET}"
    fi
  fi
}

# =============================================================================
# PHASE 4: PREFERENCES
# =============================================================================

apply_preferences() {
  make_banner "Preferences & Configuration" "$NORD_CYAN"

  # Set ZSH as default shell
  if [[ "$SHELL" != *"zsh"* ]] && command_exists zsh; then
    local response
    response=$(prompt_user "Set ZSH as default shell?" "N")
    if is_yes "$response"; then
      local zsh_path
      zsh_path=$(which zsh)
      grep -q "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
      chsh -s "$zsh_path" "$USER" && echo -e "${NORD_GREEN}✓ ZSH set as default shell${RESET}" || echo -e "${NORD_RED}Failed to set ZSH${RESET}"
    fi
  else
    echo -e "${NORD_GREEN}✓ ZSH is already default shell${RESET}"
  fi

  # XDG migrations
  if [[ -f "./scripts/migrate-xdg.sh" ]]; then
    local response
    response=$(prompt_user "Run XDG directory migrations?" "N")
    if is_yes "$response"; then
      chmod +x "./scripts/migrate-xdg.sh" && "./scripts/migrate-xdg.sh"
    fi
  fi

  # ZSH plugins
  if command_exists zsh; then
    local response
    response=$(prompt_user "Install/update ZSH plugins?" "N")
    if is_yes "$response"; then
      if ANTIGEN_UPDATING=1 /bin/zsh -i -c "antigen update && antigen-apply"; then
        echo -e "${NORD_GREEN}✓ ZSH plugins updated${RESET}"
      else
        echo -e "${NORD_RED}Failed to update ZSH plugins${RESET}"
      fi
    fi
  fi

  # macOS system preferences
  local response
  response=$(prompt_user "Apply macOS system preferences?" "N")
  if is_yes "$response"; then
    for script in macos-preferences.sh macos-apps.sh; do
      local script_path="$MACOS_SETTINGS_DIR/$script"
      if [[ -f "$script_path" ]]; then
        echo -e "${NORD_BLUE}Running $script...${RESET}"
        chmod +x "$script_path" && "$script_path" --quick-exit --yes-to-all || echo -e "${NORD_RED}$script failed${RESET}"
      fi
    done
  fi
}

# =============================================================================
# PHASE 5: FINISHING UP
# =============================================================================

finishing_up() {
  source "${HOME}/.zshenv" 2>/dev/null || true

  local total_time=$(( $(date +%s) - START_TIME ))
  if [[ $total_time -gt 60 ]]; then
    total_time="$((total_time / 60)) minutes"
  else
    total_time="${total_time} seconds"
  fi

  make_banner "Dotfiles configured in $total_time" "$NORD_GREEN" 1

  if command_exists terminal-notifier; then
    terminal-notifier -group "dotfiles" -title "Setup Complete" \
      -message "Your dotfiles are configured and ready to use" \
      -sound "Sosumi" &>/dev/null
  fi

  echo -e "${NORD_CYAN}Press any key to exit.${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -s || true

  exit 0
}

# =============================================================================
# ARGUMENT PARSING & MAIN
# =============================================================================

# Help
if [[ "${*}" == *"--help"* ]] || [[ "${*}" == *"-h"* ]]; then
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --auto-yes    Skip all prompts (use defaults)"
  echo "  --no-clear    Don't clear the screen"
  echo "  --help, -h    Show this message"
  echo ""
  echo "Environment:"
  echo "  DOTFILES_DIR  Target directory (default: script location)"
  exit 0
fi

# Parse flags
[[ "${*}" != *"--no-clear"* ]] && clear
[[ "${*}" == *"--auto-yes"* ]] && PROMPT_TIMEOUT=1 && AUTO_YES=true

# Run phases
pre_setup_tasks "$@"
setup_dotfiles
install_packages
apply_preferences
finishing_up
