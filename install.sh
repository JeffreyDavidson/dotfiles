#!/usr/bin/env bash

# Set variables for reference
PARAMS=$* # User-specified parameters
CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
SYSTEM_TYPE=$(uname -s) # Get system type - Linux / MacOS (Darwin)
PROMPT_TIMEOUT=15 # When user is prompted for input, skip after x seconds
START_TIME=`date +%s` # Start timer
SRC_DIR=$(dirname ${0})

# Dotfiles Source Repo and Destination Directory
REPO_NAME="${REPO_NAME:-jeffreydavidson/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-${SRC_DIR:-$HOME/Projects/dotfiles}}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/${REPO_NAME}.git}"

# Config Names and Locations
TITLE="🧰 ${REPO_NAME} Setup"
SYMLINK_FILE="${SYMLINK_FILE:-symlinks.yaml}"
DOTBOT_DIR='lib/dotbot'
DOTBOT_BIN='bin/dotbot'

# Nord Color Variables
NORD_BLUE='\033[38;2;94;129;172m'      # #5E81AC - Primary accent
NORD_CYAN='\033[38;2;136;192;208m'     # #88C0D0 - Highlights  
NORD_GREEN='\033[38;2;163;190;140m'    # #A3BE8C - Success
NORD_YELLOW='\033[38;2;235;203;139m'   # #EBCB8B - Warnings
NORD_RED='\033[38;2;191;97;106m'       # #BF616A - Errors
NORD_PURPLE='\033[38;2;180;142;173m'   # #B48EAD - Special
NORD_ORANGE='\033[38;2;208;135;112m'   # #D08770 - Secondary
NORD_WHITE='\033[38;2;236;239;244m'    # #ECEFF4 - Light text
NORD_GRAY='\033[38;2;76;86;106m'       # #4C566A - Muted text
RESET='\033[0m'

# Legacy aliases for compatibility
CYAN_B=$NORD_CYAN
YELLOW_B=$NORD_YELLOW
RED_B=$NORD_RED
GREEN_B=$NORD_GREEN
PLAIN_B=$NORD_WHITE
GREEN=$NORD_GREEN
PURPLE=$NORD_PURPLE
BLUE=$NORD_BLUE

# Clear the screen
if [[ ! $PARAMS == *"--no-clear"* ]] && [[ ! $PARAMS == *"--help"* ]] ; then
  clear
fi

# If set to auto-yes - then don't wait for user reply
if [[ $PARAMS == *"--auto-yes"* ]]; then
  PROMPT_TIMEOUT=1
  AUTO_YES=true
fi

# Function that prints important text in a banner with colored border
# First param is the text to output, then optional color and padding
make_banner () {
  bannerText=$1
  lineColor="${2:-$NORD_CYAN}"
  padding="${3:-0}"
  titleLen=$(expr ${#bannerText} + 2 + $padding);
  lineChar="─"; line=""
  for (( i = 0; i < "$titleLen"; ++i )); do line="${line}${lineChar}"; done
  banner="${lineColor}╭${line}╮\n│ ${NORD_WHITE}${bannerText}${lineColor} │\n╰${line}╯"
  echo -e "\n${banner}\n${RESET}"
}

# Explain to the user what changes will be made
make_intro () {
  echo -e "${NORD_CYAN}The setup script will do the following:${RESET}\n"\
  "${NORD_BLUE}(1) Pre-Setup Tasks\n"\
  "  ${NORD_GRAY}- Check that all requirements are met, and system is compatible\n"\
  "  ${NORD_GRAY}- Sets environmental variables from params, or uses sensible defaults\n"\
  "  ${NORD_GRAY}- Output welcome message and summary of changes\n"\
  "${NORD_BLUE}(2) Setup Dotfiles\n"\
  "  ${NORD_GRAY}- Clone or update dotfiles from git\n"\
  "  ${NORD_GRAY}- Symlinks dotfiles to correct locations\n"\
  "${NORD_BLUE}(3) Install packages\n"\
  "  ${NORD_GRAY}- On MacOS, prompt to install Homebrew if not present\n"\
  "  ${NORD_GRAY}- On MacOS, updates and installs apps listed in Brewfile\n"\
  "  ${NORD_GRAY}- Checks that OS is up-to-date and critical patches are installed\n"\
  "${NORD_BLUE}(4) Configure system\n"\
  "  ${NORD_GRAY}- Setup ZSH, and install / update ZSH plugins via Antigen\n"\
  "  ${NORD_GRAY}- Apply system settings (via NSDefaults on Mac)\n"\
  "  ${NORD_GRAY}- Apply assets, wallpaper, fonts, screensaver, etc\n"\
  "${NORD_BLUE}(5) Finishing Up\n"\
  "  ${NORD_GRAY}- Refresh current terminal session\n"\
  "  ${NORD_GRAY}- Print summary of applied changes and time taken\n"\
  "  ${NORD_GRAY}- Exit with appropriate status code\n\n"\
  "${NORD_BLUE}You will be prompted at each stage, before any changes are made.${RESET}\n"\
  "${NORD_BLUE}For more info, see GitHub: ${NORD_CYAN}https://github.com/${REPO_NAME}${RESET}"
}

# Checks if a given package is installed
command_exists () {
  hash "$1" 2> /dev/null
}

# On error, displays death banner, and terminates app with exit code 1
terminate () {
  make_banner "Installation failed. Terminating..." ${RED_B}
  exit 1
}

# Checks if command / package (in $1) exists and then shows
# either shows a warning or error, depending if package required ($2)
system_verify () {
  if ! command_exists $1; then
    if $2; then
      echo -e "🚫 ${RED_B}Error:${PLAIN_B} $1 is not installed${RESET}"
      terminate
    else
      echo -e "⚠️  ${YELLOW_B}Warning:${PLAIN_B} $1 is not installed${RESET}"
    fi
  fi
}

# Prints welcome banner, verifies that requirements are met
function pre_setup_tasks () {
  # Show pretty starting banner
  make_banner "${TITLE}" "${NORD_CYAN}" 1

  # Set term title
  echo -e "\033];${TITLE}\007\033]6;1;bg;red;brightness;30\a" \
  "\033]6;1;bg;green;brightness;235\a\033]6;1;bg;blue;brightness;215\a"

  # Print intro, listing what changes will be applied
  make_intro

  # Confirm that the user would like to proceed
  echo -e "\n${NORD_CYAN}Are you happy to continue? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_start
  if [[ ! $ans_start =~ ^[Yy]$ ]] && [[ $AUTO_YES != true ]] ; then
    echo -e "\n${NORD_BLUE}No worries, feel free to come back another time."\
    "\nTerminating...${RESET}"
    make_banner "🚧 Installation Aborted" ${YELLOW_B} 1
    exit 0
  fi
  echo

  # If pre-requsite packages not found, prompt to install
  if ! command_exists git; then
    bash <(curl -s  -L 'https://raw.githubusercontent.com/JeffreyDavidson/dotfiles/refs/heads/main/scripts/installs/prerequisites.sh') $PARAMS
  fi

  # Verify required packages are installed
  system_verify "git" true
  system_verify "zsh" false

  # If XDG variables arn't yet set, then configure defaults
  if [ -z ${XDG_CONFIG_HOME+x} ]; then
    echo -e "${YELLOW_B}XDG_CONFIG_HOME is not yet set. Will use ~/.config${RESET}"
    export XDG_CONFIG_HOME="${HOME}/.config"
  fi
  if [ -z ${XDG_DATA_HOME+x} ]; then
    echo -e "${YELLOW_B}XDG_DATA_HOME is not yet set. Will use ~/.local/share${RESET}"
    export XDG_DATA_HOME="${HOME}/.local/share"
  fi

  # Ensure dotfiles source directory is set and valid
  if [[ ! -d "$SRC_DIR" ]] && [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${YELLOW_B}Destination directory not set,"\
    "defaulting to $HOME/Projects/dotfiles\n"\
    "${NORD_CYAN}To specify where you'd like dotfiles to be downloaded to,"\
    "set the DOTFILES_DIR environmental variable, and re-run.${RESET}"
    DOTFILES_DIR="${HOME}/.dotfiles"
  fi
}

# Downloads / updates dotfiles and symlinks them
function setup_dot_files () {

  # If dotfiles not yet present, clone the repo
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${NORD_BLUE}Dotfiles not yet present."\
    "Downloading ${REPO_NAME} into ${DOTFILES_DIR}${RESET}"
    echo -e "${YELLOW_B}You can change where dotfiles will be saved to,"\
    "by setting the DOTFILES_DIR env var${RESET}"
    mkdir -p "${DOTFILES_DIR}" && \
    git clone --recursive ${DOTFILES_REPO} ${DOTFILES_DIR} && \
    cd "${DOTFILES_DIR}"
  else # Dotfiles already downloaded, just fetch latest changes
    echo -e "${NORD_BLUE}Pulling changes from ${REPO_NAME} into ${DOTFILES_DIR}${RESET}"
    cd "${DOTFILES_DIR}" && \
    git pull origin main && \
    echo -e "${NORD_BLUE}Updating submodules${RESET}" && \
    git submodule update --recursive --remote --init
  fi

  # If git clone / pull failed, then exit with error
  if ! test "$?" -eq 0; then
    echo -e >&2 "${RED_B}Failed to fetch dotfiles from git${RESET}"
    terminate
  fi

  # Set up symlinks with dotbot
  echo -e "${NORD_BLUE}Setting up Symlinks${RESET}"
  cd "${DOTFILES_DIR}"
  git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
  git submodule update --init --recursive "${DOTBOT_DIR}"
  chmod +x  lib/dotbot/bin/dotbot
  "${DOTFILES_DIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${DOTFILES_DIR}" -c "${SYMLINK_FILE}" "${@}"
}

# Based on system type, uses appropriate package manager to install / updates apps
function install_packages () {
  echo -e "\n${NORD_CYAN}Would you like to install / update system packages? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_syspackages
  if [[ ! $ans_syspackages =~ ^[Yy]$ ]] && [[ $AUTO_YES != true ]] ; then
    echo -e "\n${NORD_BLUE}Skipping package installs${RESET}"
    return
  fi
  if [ "$SYSTEM_TYPE" = "Darwin" ]; then
    # Mac OS
    intall_macos_packages
  fi
}

# Setup Brew, install / update packages, organize launchpad and checks for macOS updates
function intall_macos_packages () {
  # Homebrew not installed, ask user if they'd like to download it now
  if ! command_exists brew; then
    echo -e "\n${NORD_CYAN}Would you like to install Homebrew? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -n 1 -r ans_homebrewins
    if [[ $ans_homebrewins =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
      echo -en "🍺 ${NORD_BLUE}Installing Homebrew...${RESET}\n"
      brew_url='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
      /bin/bash -c "$(curl -fsSL $brew_url)"
      export PATH=/opt/homebrew/bin:$PATH
    fi
  fi
  # Update / Install the Homebrew packages in ~/.Brewfile
  if command_exists brew && [ -f "$DOTFILES_DIR/scripts/installs/Brewfile" ]; then
    echo -e "\n${NORD_BLUE}Updating homebrew and packages...${RESET}"
    brew update # Update Brew to latest version
    brew upgrade # Upgrade all installed casks
    brew bundle --file $HOMEBREW_BUNDLE_FILE # Install all listed Brew apps
    brew cleanup # Remove stale lock files and outdated downloads
    killall Finder # Restart finder (required for some apps)
  else
    echo -e "${NORD_BLUE}Skipping Homebrew as requirements not met${RESET}"
  fi
  # Restore launchpad structure with lporg
  launchpad_layout="${DOTFILES_DIR}/config/macos/launchpad.yml"
  if command_exists lporg && [ -f $launchpad_layout ]; then
    echo -e "\n${NORD_CYAN}Would you like to restore launchpad layout? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -n 1 -r ans_restorelayout
    if [[ $ans_restorelayout =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
      echo -e "${NORD_BLUE}Restoring Launchpad Layout...${RESET}"
      yes "" | lporg load --config=$launchpad_layout
    fi
  fi
  # Check for MacOS software updates, and ask user if they'd like to install
  echo -e "\n${NORD_CYAN}Would you like to check for OSX system updates? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_macoscheck
  if [[ $ans_macoscheck =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
    echo -e "${NORD_BLUE}Checking for software updates...${RESET}"
    pending_updates=$(softwareupdate -l 2>&1)
    if [[ ! $pending_updates == *"No new software available."* ]]; then
      echo -e "${NORD_BLUE}A new version of Mac OS is availbile${RESET}"
      echo -e "${NORD_CYAN}Would you like to update to the latest version of MacOS? (y/N)${RESET}"
      read -t $PROMPT_TIMEOUT -n 1 -r ans_macosupdate
      if [[ $ans_macosupdate =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]]; then
        echo -e "${NORD_BLUE}Updating MacOS${RESET}"
        softwareupdate -i -a
      fi
    else
      echo -e "${NORD_GREEN}System is up-to-date."\
      "Running $(sw_vers -productName) version $(sw_vers -productVersion)${RESET}"
    fi
  fi
}


# Applies application-specific preferences, and runs some setup tasks
function apply_preferences () {

  # If ZSH not the default shell, ask user if they'd like to set it
  if [[ $SHELL != *"zsh"* ]] && command_exists zsh; then
    echo -e "\n${NORD_CYAN}Would you like to set ZSH as your default shell? (y/N)${RESET}"
    read -t $PROMPT_TIMEOUT -n 1 -r ans_zsh
    if [[ $ans_zsh =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
      echo -e "${NORD_BLUE}Setting ZSH as default shell${RESET}"
      chsh -s $(which zsh) $USER
    fi
  fi

  # Prompt user to update ZSH plugins, then reload each
  echo -e "\n${NORD_CYAN}Would you like to install / update ZSH plugins? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_cliplugins
  if [[ $ans_cliplugins =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
    # Install / update ZSH plugins with Antigen
    echo -e "${NORD_BLUE}Installing ZSH Plugins${RESET}"
    /bin/zsh -i -c "antigen update && antigen-apply"
  fi

  # Apply general system, app and OS security preferences (prompt user first)
  echo -e "\n${NORD_CYAN}Would you like to apply system preferences? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_syspref
  if [[ $ans_syspref =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]]; then
    if [ "$SYSTEM_TYPE" = "Darwin" ]; then
      echo -e "\n${NORD_BLUE}Applying MacOS system preferences,\
      ensure you've understood before proceeding${RESET}\n"
      macos_settings_dir="$DOTFILES_DIR/scripts/macos-setup"
      for macScript in "macos-preferences.sh" "macos-apps.sh"; do
        chmod +x $macos_settings_dir/$macScript && \
        $macos_settings_dir/$macScript --quick-exit --yes-to-all
      done
    else
      echo -e "\n${NORD_BLUE}Applying preferences to GNOME apps, ensure you've understood before proceeding${RESET}\n"
      dconf_script="$DOTFILES_DIR/scripts/linux/dconf-prefs.sh"
      chmod +x $dconf_script && $dconf_script
    fi
  fi
}

# Updates current session, and outputs summary
function finishing_up () {
  # Update source to ZSH entry point
  source "${HOME}/.zshenv"

  # Calculate time taken
  total_time=$((`date +%s`-START_TIME))
  if [[ $total_time -gt 60 ]]; then
    total_time="$(($total_time/60)) minutes"
  else
    total_time="${total_time} seconds"
  fi

  # Print success msg and pretty picture
  make_banner "✨ Dotfiles configured succesfully in $total_time" ${GREEN_B} 1
  echo -e "\033[0;92m     .--.\n    |o_o |\n    |:_/ |\n   // \
  \ \\ \n  (|     | ) \n /'\_   _/\`\\ \n \\___)=(___/\n"

  # Refresh ZSH sesssion
  SKIP_WELCOME=true || exec zsh

  # Show popup
  if command_exists terminal-notifier; then
    terminal-notifier -group 'dotfiles' -title $TITLE  -subtitle 'All Tasks Complete' \
    -message "Your dotfiles are now configured and ready to use 🥳" \
    -appIcon ./.github/logo.png -contentImage ./.github/logo.png \
    -remove 'ALL' -sound 'Sosumi' &> /dev/null
  fi

  # Show press any key to exit
  echo -e "${NORD_CYAN}Press any key to exit.${RESET}\n"
  read -t $PROMPT_TIMEOUT -n 1 -s

  # Bye
  exit 0
}

# Let's Begin!
pre_setup_tasks   # Print start message, and check requirements are met
setup_dot_files   # Clone / update dotfiles, and create the symlinks
install_packages  # Prompt to install / update OS-specific packages
apply_preferences # Apply settings for individual applications
finishing_up      # Refresh current session, print summary and exit
