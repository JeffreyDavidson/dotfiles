#!/usr/bin/env bash

# =============================================================================
# JeffreyDavidson/Dotfiles Installation Script
# =============================================================================
# Comprehensive dotfiles installation and configuration script
# Supports macOS and Linux with robust error handling and validation
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Set variables for reference
PARAMS=$* # User-specified parameters
CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)
SYSTEM_TYPE=$(uname -s) # Get system type - Linux / MacOS (Darwin)
PROMPT_TIMEOUT=15 # When user is prompted for input, skip after x seconds
START_TIME=`date +%s` # Start timer
SRC_DIR=$(dirname ${0})

# Dotfiles Source Repo and Destination Directory
REPO_NAME="${REPO_NAME:-jeffreydavidson/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-${SRC_DIR:-$HOME/dotfiles}}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/${REPO_NAME}.git}"

# Config Names and Locations
TITLE="🧰 ${REPO_NAME} Setup"
DOTBOT_CONFIG="${DOTBOT_CONFIG:-symlinks.yaml}"
DOTBOT_DIR='lib/dotbot'
DOTBOT_BIN='bin/dotbot'

# =============================================================================
# CONFIGURATION
# =============================================================================

# Network and retry configuration
NETWORK_TIMEOUT=30
MAX_RETRIES=3
RETRY_DELAY=2
CONNECT_TIMEOUT=10

# Git configuration
GIT_DEFAULT_BRANCH="main"
GIT_SUBMODULE_JOBS=4

# External URLs
HOMEBREW_INSTALL_URL='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
PREREQUISITE_URL="https://raw.githubusercontent.com/${REPO_NAME}/refs/heads/${GIT_DEFAULT_BRANCH}/scripts/installs/prerequisites.sh"

# File paths and directories
BREWFILE_PATH="${DOTFILES_DIR}/scripts/installs/Brewfile"
LAUNCHPAD_LAYOUT_PATH="${DOTFILES_DIR}/config/macos/launchpad.yml"
GPG_SETUP_SCRIPT="./scripts/setup-gpg-xdg.sh"
EARLY_XDG_SCRIPT="./scripts/setup-xdg-early.sh"
DOCKER_XDG_SCRIPT="./scripts/setup-docker-xdg.sh"
DEV_TOOLS_XDG_SCRIPT="./scripts/setup-dev-tools-xdg.sh"
SSH_XDG_SCRIPT="./scripts/setup-ssh-xdg.sh"
REMAINING_XDG_SCRIPT="./scripts/setup-remaining-xdg.sh"
MACOS_SETTINGS_DIR="${DOTFILES_DIR}/scripts/macos-setup"
LINUX_DCONF_SCRIPT="${DOTFILES_DIR}/scripts/linux/dconf-prefs.sh"

# macOS specific scripts
MACOS_SCRIPTS=("macos-preferences.sh" "macos-apps.sh")

# Required system commands
REQUIRED_COMMANDS=("git" "curl" "chmod" "mkdir")
OPTIONAL_COMMANDS=("zsh" "brew" "lporg")

# Homebrew configuration
HOMEBREW_PATHS=("/opt/homebrew/bin" "/usr/local/bin")

# Terminal notification settings
NOTIFICATION_GROUP="dotfiles"
NOTIFICATION_SOUND="Sosumi"
LOGO_PATH="./.github/logo.png"

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

# =============================================================================
# LOGGING AND DEBUG UTILITIES
# =============================================================================

# Initialize default values (required for functions below)
DEBUG_MODE=${DEBUG_MODE:-false}
AUTO_YES=${AUTO_YES:-false}

# Debug logging function
debug_log() {
  if [[ $DEBUG_MODE == true ]]; then
    echo -e "${NORD_GRAY}[DEBUG $(date '+%H:%M:%S')] $*${RESET}" >&2
  fi
}

# Info logging function
info_log() {
  echo -e "${NORD_BLUE}[INFO $(date '+%H:%M:%S')] $*${RESET}"
}

# Warning logging function
warn_log() {
  echo -e "${YELLOW_B}[WARN $(date '+%H:%M:%S')] $*${RESET}" >&2
}

# Error logging function
error_log() {
  echo -e "${RED_B}[ERROR $(date '+%H:%M:%S')] $*${RESET}" >&2
}

# Success logging function
success_log() {
  echo -e "${GREEN}[SUCCESS $(date '+%H:%M:%S')] $*${RESET}"
}

# Log system information for debugging
log_system_info() {
  if [[ $DEBUG_MODE == true ]]; then
    debug_log "System Information:"
    debug_log "  OS: $(uname -a)"
    debug_log "  Shell: $SHELL"
    debug_log "  User: $USER"
    debug_log "  PWD: $PWD"
    debug_log "  DOTFILES_DIR: $DOTFILES_DIR"
    debug_log "  DOTFILES_REPO: $DOTFILES_REPO"
    debug_log "  XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-unset}"
    debug_log "  XDG_DATA_HOME: ${XDG_DATA_HOME:-unset}"
    debug_log "  PATH: $PATH"
  fi
}

# =============================================================================
# ERROR HANDLING AND VALIDATION
# =============================================================================

# Global error handling
trap 'handle_error $? $LINENO' ERR
trap 'cleanup_on_exit' EXIT INT TERM

# Error handling function
handle_error() {
  local exit_code=$1
  local line_number=$2
  error_log "Script failed at line $line_number with exit code $exit_code"
  error_log "Command that failed: ${BASH_COMMAND}"

  if [[ -n "${LOG_FILE:-}" ]]; then
    error_log "Full log available at: $LOG_FILE"
  fi

  echo -e "\n${RED_B}❌ Error occurred in install.sh at line $line_number (exit code: $exit_code)${RESET}"
  echo -e "${NORD_GRAY}Command: ${BASH_COMMAND}${RESET}"
  echo -e "${NORD_GRAY}Please check the output above for details${RESET}"

  cleanup_on_exit
  exit $exit_code
}

# Cleanup function for exit
cleanup_on_exit() {
  debug_log "Performing cleanup..."

  # Restore cursor if it was hidden
  echo -e "\033[?25h"

  # Reset terminal color
  echo -e "${RESET}"

  # Log cleanup completion
  if [[ -n "${LOG_FILE:-}" ]] && [[ $DEBUG_MODE == true ]]; then
    debug_log "Cleanup completed. Log file: $LOG_FILE"
  fi
}

# Validate system requirements
validate_system_requirements() {
  local errors=0

  debug_log "Starting system requirements validation"
  log_system_info

  # Check operating system
  debug_log "Validating operating system: $SYSTEM_TYPE"
  case "$SYSTEM_TYPE" in
    "Darwin"|"Linux")
      success_log "Supported OS: $SYSTEM_TYPE"
      echo -e "${GREEN}✅ Supported OS: $SYSTEM_TYPE${RESET}"
      ;;
    *)
      error_log "Unsupported operating system: $SYSTEM_TYPE"
      echo -e "${RED_B}❌ Unsupported operating system: $SYSTEM_TYPE${RESET}"
      ((errors++))
      ;;
  esac

  # Check required commands
  info_log "Checking required commands"
  echo -e "${NORD_BLUE}Checking required commands...${RESET}"
  for cmd in "${REQUIRED_COMMANDS[@]}"; do
    debug_log "Checking for command: $cmd"
    if command_exists "$cmd"; then
      debug_log "Found command: $cmd at $(command -v "$cmd")"
      echo -e "  ${GREEN}✓ $cmd${RESET}"
    else
      error_log "Missing required command: $cmd"
      echo -e "  ${RED_B}❌ $cmd (required)${RESET}"
      ((errors++))
    fi
  done

  # Check optional commands
  info_log "Checking optional commands"
  echo -e "${NORD_BLUE}Checking optional commands...${RESET}"
  for cmd in "${OPTIONAL_COMMANDS[@]}"; do
    debug_log "Checking for optional command: $cmd"
    if command_exists "$cmd"; then
      debug_log "Found optional command: $cmd at $(command -v "$cmd")"
      echo -e "  ${GREEN}✓ $cmd${RESET}"
    else
      debug_log "Optional command not found: $cmd"
      echo -e "  ${YELLOW_B}⚠️  $cmd (optional)${RESET}"
    fi
  done

  # Check network connectivity
  echo -e "${NORD_BLUE}Checking network connectivity...${RESET}"
  if curl -s --connect-timeout $CONNECT_TIMEOUT "https://github.com" >/dev/null; then
    echo -e "  ${GREEN}✓ Internet connection${RESET}"
  else
    echo -e "  ${RED_B}❌ No internet connection or GitHub unreachable${RESET}"
    ((errors++))
  fi

  # Check available disk space (at least 1GB)
  echo -e "${NORD_BLUE}Checking disk space...${RESET}"
  local available_space
  if command_exists df; then
    available_space=$(df "$(dirname "$DOTFILES_DIR")" 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
    if [[ $available_space -gt 1048576 ]]; then  # 1GB in KB
      echo -e "  ${GREEN}✓ Sufficient disk space${RESET}"
    else
      echo -e "  ${YELLOW_B}⚠️  Low disk space (less than 1GB available)${RESET}"
    fi
  fi

  if [[ $errors -gt 0 ]]; then
    error_log "System validation failed with $errors error(s)"
    echo -e "\n${RED_B}System validation failed with $errors error(s).${RESET}"
    echo -e "${NORD_BLUE}Please resolve these issues before continuing.${RESET}"
    return 1
  fi

  success_log "System validation passed"
  echo -e "\n${GREEN}✅ System validation passed${RESET}"
  return 0
}

# Validate directory permissions
validate_directory_permissions() {
  local dir="$1"
  local parent_dir="$(dirname "$dir")"

  # Check if parent directory is writable
  if [[ ! -w "$parent_dir" ]]; then
    echo -e "${RED_B}❌ Parent directory is not writable: $parent_dir${RESET}"
    return 1
  fi

  # If directory exists, check if it's writable
  if [[ -d "$dir" ]] && [[ ! -w "$dir" ]]; then
    echo -e "${RED_B}❌ Directory is not writable: $dir${RESET}"
    return 1
  fi

  return 0
}

# Retry function with exponential backoff
retry_with_backoff() {
  local max_attempts="$1"
  local delay="$2"
  local command="${@:3}"
  local attempt=1

  debug_log "Retrying command with backoff: $command (max attempts: $max_attempts)"

  while [[ $attempt -le $max_attempts ]]; do
    debug_log "Attempt $attempt/$max_attempts: $command"
    if eval "$command"; then
      debug_log "Command succeeded on attempt $attempt"
      return 0
    else
      if [[ $attempt -lt $max_attempts ]]; then
        warn_log "Command failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..."
        echo -e "${YELLOW_B}⚠️  Command failed (attempt $attempt/$max_attempts). Retrying in ${delay}s...${RESET}"
        sleep "$delay"
        delay=$((delay * 2))  # Exponential backoff
      fi
      ((attempt++))
    fi
  done

  error_log "Command failed after $max_attempts attempts: $command"
  echo -e "${RED_B}❌ Command failed after $max_attempts attempts${RESET}"
  return 1
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function that prints important text in a banner with colored border
# First param is the text to output, then optional color and padding
make_banner() {
  bannerText=$1
  lineColor="${2:-$NORD_CYAN}"
  padding="${3:-0}"
  titleLen=$(expr ${#bannerText} + 2 + $padding);
  lineChar="─"; line=""
  for (( i = 0; i < "$titleLen"; ++i )); do line="${line}${lineChar}"; done
  banner="${lineColor}╭${line}╮\n│ ${NORD_WHITE}${bannerText}${lineColor} │\n╰${line}╯"
  echo -e "\n${banner}\n${RESET}"
}

# =============================================================================
# HELP SYSTEM
# =============================================================================

# Display comprehensive help information
show_help() {
  make_banner "📚 JeffreyDavidson/Dotfiles Help" "$NORD_CYAN" 2

  echo -e "${NORD_BLUE}DESCRIPTION:${RESET}"
  echo -e "  Comprehensive dotfiles installation and configuration script for macOS and Linux."
  echo -e "  Automates the setup of development environment, applications, and system preferences."
  echo -e ""

  echo -e "${NORD_BLUE}USAGE:${RESET}"
  echo -e "  ./install.sh [OPTIONS]"
  echo -e ""

  echo -e "${NORD_BLUE}OPTIONS:${RESET}"
  echo -e "  ${GREEN}--auto-yes${RESET}          Skip all prompts and use default 'yes' responses"
  echo -e "  ${GREEN}--no-clear${RESET}          Don't clear the screen at startup"
  echo -e "  ${GREEN}--debug${RESET}             Enable debug mode with verbose logging"
  echo -e "  ${GREEN}--log${RESET}               Enable logging to file"
  echo -e "  ${GREEN}--help, -h${RESET}          Show this help message"
  echo -e ""

  echo -e "${NORD_BLUE}ENVIRONMENT VARIABLES:${RESET}"
  echo -e "  ${GREEN}DOTFILES_DIR${RESET}        Target directory for dotfiles (default: $HOME/dotfiles)"
  echo -e "  ${GREEN}DOTFILES_REPO${RESET}       Repository URL (default: github.com/jeffreyDavidson/dotfiles.git)"
  echo -e "  ${GREEN}REPO_NAME${RESET}           Repository name (default: jeffreydavidson/dotfiles)"
  echo -e "  ${GREEN}XDG_CONFIG_HOME${RESET}     XDG config directory (default: ~/.config)"
  echo -e "  ${GREEN}XDG_DATA_HOME${RESET}       XDG data directory (default: ~/.local/share)"
  echo -e ""

  echo -e "${NORD_BLUE}INSTALLATION PHASES:${RESET}"
  echo -e "  ${NORD_PURPLE}1. Pre-Setup${RESET}         System validation and environment setup"
  echo -e "  ${NORD_PURPLE}2. Dotfiles Setup${RESET}    Clone/update repository and create symlinks"
  echo -e "  ${NORD_PURPLE}3. Package Management${RESET} Install/update system packages (Homebrew on macOS)"
  echo -e "  ${NORD_PURPLE}4. Preferences${RESET}       Configure shell, plugins, and system settings"
  echo -e "  ${NORD_PURPLE}5. Finishing${RESET}        Refresh environment and display summary"
  echo -e ""

  echo -e "${NORD_BLUE}EXAMPLES:${RESET}"
  echo -e "  ${NORD_GRAY}# Interactive installation (recommended)${RESET}"
  echo -e "  ./install.sh"
  echo -e ""
  echo -e "  ${NORD_GRAY}# Non-interactive installation${RESET}"
  echo -e "  ./install.sh --auto-yes"
  echo -e ""
  echo -e "  ${NORD_GRAY}# Debug mode with logging${RESET}"
  echo -e "  ./install.sh --debug --log"
  echo -e ""
  echo -e "  ${NORD_GRAY}# Custom dotfiles directory${RESET}"
  echo -e "  DOTFILES_DIR=~/my-config ./install.sh"
  echo -e ""

  echo -e "${NORD_BLUE}FILES AND DIRECTORIES:${RESET}"
  echo -e "  ${GREEN}symlinks.yaml${RESET}       Main configuration file for dotbot"
  echo -e "  ${GREEN}scripts/installs/Brewfile${RESET} macOS package definitions"
  echo -e "  ${GREEN}config/${RESET}             Application configurations"
  echo -e "  ${GREEN}lib/dotbot/${RESET}         Dotbot symlink manager"
  echo -e ""

  echo -e "${NORD_BLUE}TROUBLESHOOTING:${RESET}"
  echo -e "  ${YELLOW_B}System validation fails:${RESET}   Install missing required commands"
  echo -e "  ${YELLOW_B}Git clone fails:${RESET}           Check network connection and repository URL"
  echo -e "  ${YELLOW_B}Symlink creation fails:${RESET}    Check file permissions and existing files"
  echo -e "  ${YELLOW_B}Package installation fails:${RESET} Check package manager installation"
  echo -e ""
  echo -e "  For detailed troubleshooting, run with: ${GREEN}--debug --log${RESET}"
  echo -e ""

  echo -e "${NORD_BLUE}MORE INFORMATION:${RESET}"
  echo -e "  Repository: ${NORD_CYAN}https://github.com/${REPO_NAME}${RESET}"
  echo -e "  Issues:     ${NORD_CYAN}https://github.com/${REPO_NAME}/issues${RESET}"
  echo -e "  Wiki:       ${NORD_CYAN}https://github.com/${REPO_NAME}/wiki${RESET}"
  echo -e ""
}

# Check for help flag and display help if requested
if [[ "$*" == *"--help"* ]] || [[ "$*" == *"-h"* ]]; then
  show_help
  exit 0
fi

# Clear the screen
if [[ ! $PARAMS == *"--no-clear"* ]] && [[ ! $PARAMS == *"--help"* ]] ; then
  clear
fi

# If set to auto-yes - then don't wait for user reply
if [[ $PARAMS == *"--auto-yes"* ]]; then
  PROMPT_TIMEOUT=1
  AUTO_YES=true
fi

# Enable debug mode if requested
if [[ $PARAMS == *"--debug"* ]]; then
  DEBUG_MODE=true
  set -x  # Enable command tracing
else
  DEBUG_MODE=false
fi

# Setup logging if requested
if [[ $PARAMS == *"--log"* ]] || [[ $DEBUG_MODE == true ]]; then
  LOG_FILE="${HOME}/.cache/dotfiles-install-$(date +%Y%m%d-%H%M%S).log"
  mkdir -p "$(dirname "$LOG_FILE")"
  exec 1> >(tee -a "$LOG_FILE")
  exec 2> >(tee -a "$LOG_FILE" >&2)
  echo -e "${NORD_BLUE}Logging enabled: $LOG_FILE${RESET}"
fi


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
  command -v "$1" >/dev/null 2>&1
}

# Show a progress spinner
show_spinner() {
  local pid=$1
  local message="$2"
  local spinner_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0

  # Hide cursor
  echo -ne "\033[?25l"

  echo -n "${NORD_BLUE}$message ${RESET}"
  while kill -0 $pid 2>/dev/null; do
    printf "\r${NORD_BLUE}$message ${spinner_chars:$i:1}${RESET}"
    i=$(((i + 1) % ${#spinner_chars}))
    sleep 0.1
  done

  # Show cursor and print completion
  echo -ne "\033[?25h"
  printf "\r${NORD_BLUE}$message ${GREEN}✓${RESET}\n"
}

# Show progress bar
show_progress_bar() {
  local current=$1
  local total=$2
  local message="${3:-Progress}"
  local width=50
  local percentage=$((current * 100 / total))
  local completed=$((current * width / total))
  local remaining=$((width - completed))

  printf "\r${NORD_BLUE}$message [${GREEN}%*s${NORD_GRAY}%*s${NORD_BLUE}] %d%%${RESET}" \
    $completed "" $remaining "" $percentage | tr ' ' '█' | sed "s/█/${GREEN}█/g; s/$/${RESET}/"

  if [[ $current -eq $total ]]; then
    echo ""
  fi
}

# Enhanced user prompt with better formatting
prompt_user() {
  local message="$1"
  local default="${2:-N}"
  local timeout="${3:-$PROMPT_TIMEOUT}"
  local response
  response=""

  local prompt_text="${NORD_CYAN}❓ $message${RESET}"
  if [[ "$default" == [Yy] ]]; then
    prompt_text="$prompt_text ${NORD_GRAY}[Y/n]${RESET}"
  else
    prompt_text="$prompt_text ${NORD_GRAY}[y/N]${RESET}"
  fi

  if [[ $AUTO_YES == true ]]; then
    echo -e "${NORD_GRAY}Auto-yes enabled, using default: $default${RESET}"
    echo "$default"
    return 0
  fi

  # Make sure prompt displays even if stdout is redirected
  echo -e "$prompt_text" >/dev/tty
  read -t "$timeout" -n 1 -r response </dev/tty
  echo >/dev/tty

  if [[ -z "$response" ]]; then
    response="${response:-$default}"
  fi

  echo "$response"
}

# Check if user response is positive
is_yes() {
  local response="$1"
  [[ "$response" =~ ^[Yy]$ ]]
}

# Display a formatted section header
show_section() {
  local title="$1"
  local color="${2:-$NORD_CYAN}"

  echo -e "\n${color}┌" + "─" * $((${#title} + 4)) + "┐${RESET}"
  echo -e "${color}│  $title  │${RESET}"
  echo -e "${color}└" + "─" * $((${#title} + 4)) + "┘${RESET}\n"
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
function pre_setup_tasks() {
  # Show pretty starting banner
  make_banner "${TITLE}" "${NORD_CYAN}" 1

  # Set term title
  echo -e "\033];${TITLE}\007\033]6;1;bg;red;brightness;30\a" \
  "\033]6;1;bg;green;brightness;235\a\033]6;1;bg;blue;brightness;215\a"

  # Print intro, listing what changes will be applied
  make_intro

  # Perform comprehensive system validation
  echo -e "\n${NORD_BLUE}Performing system validation...${RESET}"
  if ! validate_system_requirements; then
    make_banner "🚧 System Validation Failed" "${RED_B}" 2
    exit 1
  fi

  # Confirm that the user would like to proceed
  local response
  response=""
  response=$(prompt_user "Ready to begin installation?" "N")

  if ! is_yes "$response"; then
    echo -e "\n${NORD_BLUE}👋 No worries! Feel free to come back another time.${RESET}"
    make_banner "🚧 Installation Aborted" "${YELLOW_B}" 1
    exit 0
  fi

  # If pre-requsite packages not found, prompt to install
  if ! command_exists git; then
    echo -e "${NORD_BLUE}Installing prerequisites...${RESET}"
    if ! retry_with_backoff $MAX_RETRIES $RETRY_DELAY "bash <(curl -s -L '$PREREQUISITE_URL') $PARAMS"; then
      echo -e "${RED_B}❌ Failed to install prerequisites${RESET}"
      exit 1
    fi
  fi

  # Verify required packages are installed after potential installation
  system_verify "git" true
  system_verify "zsh" false

  # Configure XDG variables if not set
  configure_xdg_variables

  # Validate and setup dotfiles directory
  setup_dotfiles_directory
}

# Run early XDG directory setup to prevent ~/.docker and ~/.gnupg creation
setup_early_xdg_directories() {
  local early_xdg_script="$EARLY_XDG_SCRIPT"

  # Only run if we're in the dotfiles directory and script exists
  if [[ -f "$early_xdg_script" ]]; then
    echo -e "${NORD_BLUE}Setting up early XDG directories...${RESET}"
    if chmod +x "$early_xdg_script" && "$early_xdg_script"; then
      echo -e "${GREEN}✓ Early XDG directories created${RESET}"
    else
      echo -e "${YELLOW_B}⚠️  Early XDG setup failed, continuing${RESET}"
    fi
  fi
}

# Configure XDG Base Directory variables
configure_xdg_variables() {
  if [ -z "${XDG_CONFIG_HOME+x}" ]; then
    echo -e "${YELLOW_B}XDG_CONFIG_HOME not set. Using ~/.config${RESET}"
    export XDG_CONFIG_HOME="${HOME}/.config"
  fi

  if [ -z "${XDG_DATA_HOME+x}" ]; then
    echo -e "${YELLOW_B}XDG_DATA_HOME not set. Using ~/.local/share${RESET}"
    export XDG_DATA_HOME="${HOME}/.local/share"
  fi

  if [ -z "${XDG_CACHE_HOME+x}" ]; then
    export XDG_CACHE_HOME="${HOME}/.cache"
  fi

  echo -e "${GREEN}✓ XDG variables configured${RESET}"

  # Run early XDG setup to prevent ~/.docker and ~/.gnupg creation
  setup_early_xdg_directories
}

# Setup and validate dotfiles directory
setup_dotfiles_directory() {
  # Validate dotfiles directory path
  if [[ -z "$DOTFILES_DIR" ]]; then
    echo -e "${RED_B}❌ DOTFILES_DIR cannot be empty${RESET}"
    exit 1
  fi

  # Prevent dangerous paths
  case "$DOTFILES_DIR" in
    "/"|"$HOME"|"$HOME/")
      echo -e "${RED_B}❌ Invalid DOTFILES_DIR: $DOTFILES_DIR${RESET}"
      echo -e "${NORD_GRAY}Cannot use root or home directory as dotfiles directory${RESET}"
      exit 1
      ;;
  esac

  # Validate directory permissions
  if ! validate_directory_permissions "$DOTFILES_DIR"; then
    exit 1
  fi

  # If neither source directory nor dotfiles directory exist, set default
  if [[ ! -d "$SRC_DIR" ]] && [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${YELLOW_B}Setting default dotfiles directory: $DOTFILES_DIR${RESET}"
    echo -e "${NORD_CYAN}To specify a custom location, set DOTFILES_DIR environment variable${RESET}"
  fi

  echo -e "${GREEN}✓ Dotfiles directory validated: $DOTFILES_DIR${RESET}"
}

# Downloads / updates dotfiles and symlinks them
function setup_dot_files() {
  local git_operation_failed=false

  # If dotfiles not yet present, clone the repo
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${NORD_BLUE}Cloning dotfiles repository...${RESET}"
    echo -e "${NORD_GRAY}Repository: ${DOTFILES_REPO}${RESET}"
    echo -e "${NORD_GRAY}Destination: ${DOTFILES_DIR}${RESET}"

    # Create parent directory if needed
    if ! mkdir -p "$(dirname "$DOTFILES_DIR")"; then
      echo -e "${RED_B}❌ Failed to create parent directory${RESET}"
      terminate
    fi

    # Clone with retry logic
    if ! retry_with_backoff $MAX_RETRIES $RETRY_DELAY "git clone --recursive --progress '$DOTFILES_REPO' '$DOTFILES_DIR'"; then
      echo -e "${RED_B}❌ Failed to clone dotfiles repository${RESET}"
      terminate
    fi

    cd "${DOTFILES_DIR}" || terminate
    echo -e "${GREEN}✓ Repository cloned successfully${RESET}"

  else
    # Dotfiles already downloaded, just fetch latest changes
    echo -e "${NORD_BLUE}Updating existing dotfiles repository...${RESET}"
    cd "${DOTFILES_DIR}" || terminate

    # Verify it's a git repository
    if [[ ! -d ".git" ]]; then
      echo -e "${RED_B}❌ Directory exists but is not a git repository: $DOTFILES_DIR${RESET}"
      terminate
    fi

    # Fetch latest changes with retry logic
    if ! retry_with_backoff $MAX_RETRIES $RETRY_DELAY "git pull origin '$GIT_DEFAULT_BRANCH'"; then
      echo -e "${YELLOW_B}⚠️  Failed to pull latest changes, continuing with current version${RESET}"
      git_operation_failed=true
    else
      echo -e "${GREEN}✓ Repository updated successfully${RESET}"
    fi

    # Update submodules
    echo -e "${NORD_BLUE}Updating submodules...${RESET}"
    if ! retry_with_backoff $MAX_RETRIES $RETRY_DELAY "git submodule update --recursive --remote --init --jobs='$GIT_SUBMODULE_JOBS'"; then
      echo -e "${YELLOW_B}⚠️  Failed to update submodules, continuing${RESET}"
      git_operation_failed=true
    else
      echo -e "${GREEN}✓ Submodules updated successfully${RESET}"
    fi
  fi

  # Validate critical files exist
  validate_dotfiles_structure

  # Set up symlinks with dotbot
  setup_symlinks_with_dotbot
}

# Validate that critical dotfiles structure exists
validate_dotfiles_structure() {
  local required_files=("$DOTBOT_CONFIG" "$DOTBOT_DIR/$DOTBOT_BIN")
  local missing_files=()

  echo -e "${NORD_BLUE}Validating dotfiles structure...${RESET}"

  for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
      missing_files+=("$file")
    fi
  done

  if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo -e "${RED_B}❌ Missing critical files:${RESET}"
    for file in "${missing_files[@]}"; do
      echo -e "  ${RED_B}• $file${RESET}"
    done
    terminate
  fi

  echo -e "${GREEN}✓ Dotfiles structure validated${RESET}"
}

# Set up symlinks using dotbot
setup_symlinks_with_dotbot() {
  echo -e "${NORD_BLUE}Setting up symlinks...${RESET}"

  # Ensure we're in the dotfiles directory
  cd "${DOTFILES_DIR}" || terminate

  # Sync and update dotbot submodule
  if ! git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive; then
    echo -e "${YELLOW_B}⚠️  Failed to sync dotbot submodule${RESET}"
  fi

  if ! git submodule update --init --recursive "${DOTBOT_DIR}"; then
    echo -e "${RED_B}❌ Failed to update dotbot submodule${RESET}"
    terminate
  fi

  # Make dotbot executable
  local dotbot_path="${DOTBOT_DIR}/${DOTBOT_BIN}"
  if ! chmod +x "$dotbot_path"; then
    echo -e "${RED_B}❌ Failed to make dotbot executable${RESET}"
    terminate
  fi

  # Run dotbot to create symlinks
  echo -e "${NORD_GRAY}Running dotbot with configuration: $DOTBOT_CONFIG${RESET}"
  # Pass through any additional args only if provided; avoid forwarding an empty string
  if ! "${DOTFILES_DIR}/${dotbot_path}" -d "${DOTFILES_DIR}" -c "${DOTBOT_CONFIG}" "$@"; then
    echo -e "${RED_B}❌ Dotbot symlink creation failed${RESET}"
    terminate
  fi

  echo -e "${GREEN}✓ Symlinks created successfully${RESET}"
}

# Based on system type, uses appropriate package manager to install / updates appsq
function install_packages() {
  show_section "System Packages" "$NORD_BLUE"

  echo -e "${NORD_GRAY}This will install and update system packages using your platform's package manager.${RESET}"
  echo -e "${NORD_GRAY}On macOS, this includes development tools, applications, and utilities.${RESET}\n"

  local response
  response=$(prompt_user "Install and update system packages?" "Y")

  if ! is_yes "$response"; then
    echo -e "\n${NORD_BLUE}⏭️  Skipping package installation and updates${RESET}"
    return 0
  fi

  case "$SYSTEM_TYPE" in
    "Darwin")
      install_macos_packages
      ;;
    "Linux")
      echo -e "${YELLOW_B}⚠️  Linux package management not yet implemented${RESET}"
      echo -e "${NORD_GRAY}Please install packages manually using your distribution's package manager:${RESET}"
      echo -e "${NORD_GRAY}  • Ubuntu/Debian: apt-get install <package>${RESET}"
      echo -e "${NORD_GRAY}  • CentOS/RHEL: yum install <package>${RESET}"
      echo -e "${NORD_GRAY}  • Arch: pacman -S <package>${RESET}"
      ;;
    *)
      warn_log "Package management not supported for: $SYSTEM_TYPE"
      echo -e "${YELLOW_B}⚠️  Package management not supported for: $SYSTEM_TYPE${RESET}"
      ;;
  esac

  return 0
}

# Install Homebrew if not present
install_homebrew_if_needed() {
  if ! command_exists brew; then
    show_section "Homebrew Package Manager" "$NORD_PURPLE"

    echo -e "${NORD_GRAY}Homebrew is a package manager that simplifies software installation on macOS.${RESET}"
    echo -e "${NORD_GRAY}It will be used to install development tools and applications.${RESET}\n"

    local response
    response=$(prompt_user "Install Homebrew package manager?" "Y")

    if is_yes "$response"; then
      echo -e "\n🍺 ${NORD_BLUE}Installing Homebrew...${RESET}"

      # Run installation in background to show spinner
      (
        /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)"
      ) &
      show_spinner $! "Installing Homebrew package manager"
      wait $!

      # Add Homebrew to PATH
      for brew_path in "${HOMEBREW_PATHS[@]}"; do
        if [[ -d "$brew_path" ]] && [[ ":$PATH:" != *":$brew_path:"* ]]; then
          export PATH="$brew_path:$PATH"
        fi
      done

      # Verify installation
      if ! command_exists brew; then
        error_log "Homebrew installation failed"
        echo -e "${RED_B}❌ Homebrew installation failed${RESET}"
        return 1
      fi

      success_log "Homebrew installed successfully"
      echo -e "${GREEN}✅ Homebrew installed successfully${RESET}"
    else
      echo -e "\n${NORD_BLUE}⏭️  Skipping Homebrew installation${RESET}"
      return 1
    fi
  else
    echo -e "${GREEN}✅ Homebrew is already installed${RESET}"
  fi
  return 0
}

# Update and install Homebrew packages
update_homebrew_packages() {
  local brewfile="$BREWFILE_PATH"

  if ! command_exists brew; then
    echo -e "${NORD_BLUE}Skipping package updates - Homebrew not available${RESET}"
    return 1
  fi

  if [[ ! -f "$brewfile" ]]; then
    echo -e "${NORD_YELLOW}⚠️  Brewfile not found at $brewfile${RESET}"
    return 1
  fi

  echo -e "\n${NORD_BLUE}Updating homebrew and packages...${RESET}"

  # Update Brew to latest version
  echo -e "${NORD_GRAY}Updating Homebrew...${RESET}"
  brew update

  # Upgrade all installed packages
  echo -e "${NORD_GRAY}Upgrading installed packages...${RESET}"
  brew upgrade

  # Install all listed Brew apps
  echo -e "${NORD_GRAY}Installing packages from Brewfile...${RESET}"
  brew bundle --file "$brewfile"

  # Remove stale lock files and outdated downloads
  echo -e "${NORD_GRAY}Cleaning up...${RESET}"
  brew cleanup

  # Restart finder (required for some apps)
  killall Finder 2>/dev/null || true

  echo -e "${NORD_GREEN}✅ Package management complete${RESET}"
  return 0
}

# Restore launchpad layout using lporg
restore_launchpad_layout() {
  local launchpad_layout="$LAUNCHPAD_LAYOUT_PATH"

  if ! command_exists lporg; then
    return 1
  fi

  if [[ ! -f "$launchpad_layout" ]]; then
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to restore launchpad layout? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_restorelayout
  if [[ $ans_restorelayout =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
    echo -e "${NORD_BLUE}Restoring Launchpad Layout...${RESET}"
    lporg load --config="$launchpad_layout" --yes --no-backup
    echo -e "${NORD_GREEN}✅ Launchpad layout restored${RESET}"
  else
    echo -e "\n${NORD_BLUE}Skipping launchpad layout restoration${RESET}"
  fi
}

# Check for and install macOS system updates
check_macos_updates() {
  echo -e "\n${NORD_CYAN}Would you like to check for macOS system updates? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_macoscheck
  if [[ $ans_macoscheck =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
    echo -e "${NORD_BLUE}Checking for software updates...${RESET}"

    local pending_updates
    pending_updates=$(softwareupdate -l 2>&1)

    if [[ ! $pending_updates == *"No new software available."* ]]; then
      echo -e "${NORD_BLUE}📱 A new version of macOS is available${RESET}"
      echo -e "${NORD_CYAN}Would you like to update to the latest version of macOS? (y/N)${RESET}"
      read -t $PROMPT_TIMEOUT -n 1 -r ans_macosupdate
      if [[ $ans_macosupdate =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]]; then
        echo -e "${NORD_BLUE}Updating macOS (this may take a while)...${RESET}"
        softwareupdate -i -a
        echo -e "${NORD_GREEN}✅ macOS update complete${RESET}"
      else
        echo -e "\n${NORD_BLUE}Skipping macOS update${RESET}"
      fi
    else
      echo -e "${NORD_GREEN}✅ System is up-to-date."\
      "Running $(sw_vers -productName) version $(sw_vers -productVersion)${RESET}"
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping system update check${RESET}"
  fi
}

# Main macOS package management function
function install_macos_packages() {
  install_homebrew_if_needed
  update_homebrew_packages
  restore_launchpad_layout
  check_macos_updates
}


# Set ZSH as the default shell if not already set
setup_default_shell() {
  if [[ $SHELL == *"zsh"* ]]; then
    echo -e "${NORD_GREEN}✅ ZSH is already your default shell${RESET}"
    return 0
  fi

  if ! command_exists zsh; then
    echo -e "${NORD_YELLOW}⚠️  ZSH not found, skipping shell setup${RESET}"
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to set ZSH as your default shell? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_zsh
  if [[ $ans_zsh =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
    echo -e "${NORD_BLUE}Setting ZSH as default shell...${RESET}"

    local zsh_path
    zsh_path=$(which zsh)

    # Add zsh to /etc/shells if not present
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change the default shell
    if chsh -s "$zsh_path" "$USER"; then
      echo -e "${NORD_GREEN}✅ ZSH set as default shell (restart terminal to apply)${RESET}"
    else
      echo -e "${NORD_RED}❌ Failed to set ZSH as default shell${RESET}"
      return 1
    fi
  else
    echo -e "\n${NORD_BLUE}Keeping current shell: $SHELL${RESET}"
  fi
}

# Setup development tools with XDG compliance
setup_dev_tools_xdg() {
  local dev_tools_script="$DEV_TOOLS_XDG_SCRIPT"

  if [[ ! -f "$dev_tools_script" ]]; then
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to migrate development tools (npm) to XDG locations? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_devtools
  if [[ $ans_devtools =~ ^[Yy]$ ]] || [[ $AUTO_YES == true ]] ; then
    echo -e "${NORD_BLUE}Setting up development tools with XDG compliance...${RESET}"

    if chmod +x "$dev_tools_script" && "$dev_tools_script"; then
      echo -e "${NORD_GREEN}✅ Development tools XDG setup complete${RESET}"
    else
      echo -e "${NORD_RED}❌ Development tools XDG setup failed${RESET}"
      return 1
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping development tools XDG setup${RESET}"
  fi
}

# Setup SSH with XDG compliance
setup_ssh_xdg() {
  local ssh_script="$SSH_XDG_SCRIPT"

  if [[ ! -f "$ssh_script" ]]; then
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to migrate SSH configuration to XDG location? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_ssh
  if [[ $ans_ssh =~ ^[Yy]$ ]] || [[ $AUTO_YES == true ]] ; then
    echo -e "${NORD_BLUE}Setting up SSH with XDG compliance...${RESET}"

    if chmod +x "$ssh_script" && "$ssh_script"; then
      echo -e "${NORD_GREEN}✅ SSH XDG setup complete${RESET}"
    else
      echo -e "${NORD_RED}❌ SSH XDG setup failed${RESET}"
      return 1
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping SSH XDG setup${RESET}"
  fi
}

# Setup remaining applications with XDG compliance
setup_remaining_xdg() {
  local remaining_script="$REMAINING_XDG_SCRIPT"

  if [[ ! -f "$remaining_script" ]]; then
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to clean up remaining directories and migrate supported apps to XDG? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_remaining
  if [[ $ans_remaining =~ ^[Yy]$ ]] || [[ $AUTO_YES == true ]] ; then
    echo -e "${NORD_BLUE}Cleaning up remaining directories with XDG compliance...${RESET}"

    if chmod +x "$remaining_script" && "$remaining_script"; then
      echo -e "${NORD_GREEN}✅ Remaining directories cleanup complete${RESET}"
    else
      echo -e "${NORD_RED}❌ Remaining directories cleanup failed${RESET}"
      return 1
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping remaining directories cleanup${RESET}"
  fi
}

# Setup Docker with XDG compliance
setup_docker_xdg() {
  local docker_script="$DOCKER_XDG_SCRIPT"

  if [[ ! -f "$docker_script" ]]; then
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to setup Docker with XDG compliance? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_docker
  if [[ $ans_docker =~ ^[Yy]$ ]] || [[ $AUTO_YES == true ]] ; then
    echo -e "${NORD_BLUE}Setting up Docker with XDG compliance...${RESET}"

    if chmod +x "$docker_script" && "$docker_script"; then
      echo -e "${NORD_GREEN}✅ Docker XDG setup complete${RESET}"
    else
      echo -e "${NORD_RED}❌ Docker XDG setup failed${RESET}"
      return 1
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping Docker XDG setup${RESET}"
  fi
}

# Setup GPG with XDG compliance
setup_gpg_xdg() {
  local gpg_script="$GPG_SETUP_SCRIPT"

  if [[ ! -f "$gpg_script" ]] || [[ "$SYSTEM_TYPE" != "Darwin" ]]; then
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to setup GPG with XDG compliance? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_gpg
  if [[ $ans_gpg =~ ^[Yy]$ ]] || [[ $AUTO_YES == true ]] ; then
    echo -e "${NORD_BLUE}Setting up GPG with XDG compliance...${RESET}"

    if chmod +x "$gpg_script" && "$gpg_script"; then
      echo -e "${NORD_GREEN}✅ GPG XDG setup complete${RESET}"
    else
      echo -e "${NORD_RED}❌ GPG XDG setup failed${RESET}"
      return 1
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping GPG XDG setup${RESET}"
  fi
}

# Install and update ZSH plugins using Antigen
install_zsh_plugins() {
  if ! command_exists zsh; then
    echo -e "${NORD_YELLOW}⚠️  ZSH not found, skipping plugin installation${RESET}"
    return 1
  fi

  echo -e "\n${NORD_CYAN}Would you like to install / update ZSH plugins? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_cliplugins
  if [[ $ans_cliplugins =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]] ; then
    echo -e "${NORD_BLUE}Installing ZSH plugins...${RESET}"

    # Install / update ZSH plugins with Antigen
    if /bin/zsh -i -c "antigen update && antigen-apply"; then
      echo -e "${NORD_GREEN}✅ ZSH plugins updated successfully${RESET}"
    else
      echo -e "${NORD_RED}❌ Failed to update ZSH plugins${RESET}"
      return 1
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping ZSH plugin installation${RESET}"
  fi
}

# Apply system-specific preferences and settings
apply_system_preferences() {
  echo -e "\n${NORD_CYAN}Would you like to apply system preferences? (y/N)${RESET}"
  read -t $PROMPT_TIMEOUT -n 1 -r ans_syspref
  if [[ $ans_syspref =~ ^[Yy]$ ]] || [[ $AUTO_YES = true ]]; then
    if [ "$SYSTEM_TYPE" = "Darwin" ]; then
      echo -e "\n${NORD_BLUE}Applying macOS system preferences...${RESET}"
      echo -e "${NORD_YELLOW}⚠️  Please ensure you've reviewed these scripts before proceeding${RESET}\n"

      local macos_settings_dir="$MACOS_SETTINGS_DIR"
      local scripts=("${MACOS_SCRIPTS[@]}")

      for script in "${scripts[@]}"; do
        local script_path="$macos_settings_dir/$script"
        if [[ -f "$script_path" ]]; then
          echo -e "${NORD_BLUE}Running $script...${RESET}"
          if chmod +x "$script_path" && "$script_path" --quick-exit --yes-to-all; then
            echo -e "${NORD_GREEN}✅ $script completed${RESET}"
          else
            echo -e "${NORD_RED}❌ $script failed${RESET}"
          fi
        else
          echo -e "${NORD_YELLOW}⚠️  Script not found: $script_path${RESET}"
        fi
      done

    else
      echo -e "\n${NORD_BLUE}Applying preferences to GNOME apps...${RESET}"
      echo -e "${NORD_YELLOW}⚠️  Please ensure you've reviewed this script before proceeding${RESET}\n"

      local dconf_script="$LINUX_DCONF_SCRIPT"
      if [[ -f "$dconf_script" ]]; then
        if chmod +x "$dconf_script" && "$dconf_script"; then
          echo -e "${NORD_GREEN}✅ GNOME preferences applied${RESET}"
        else
          echo -e "${NORD_RED}❌ Failed to apply GNOME preferences${RESET}"
        fi
      else
        echo -e "${NORD_YELLOW}⚠️  GNOME preferences script not found${RESET}"
      fi
    fi
  else
    echo -e "\n${NORD_BLUE}Skipping system preferences${RESET}"
  fi
}

# Main preferences application function
function apply_preferences() {
  setup_default_shell
  setup_dev_tools_xdg
  setup_ssh_xdg
  setup_docker_xdg
  setup_gpg_xdg
  setup_remaining_xdg
  install_zsh_plugins
  apply_system_preferences
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
    terminal-notifier -group "$NOTIFICATION_GROUP" -title "$TITLE" -subtitle 'All Tasks Complete' \
    -message "Your dotfiles are now configured and ready to use 🥳" \
    -appIcon "$LOGO_PATH" -contentImage "$LOGO_PATH" \
    -remove 'ALL' -sound "$NOTIFICATION_SOUND" &> /dev/null
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
