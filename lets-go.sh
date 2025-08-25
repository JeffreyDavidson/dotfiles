#!/bin/bash

# =============================================================================
# JeffreyDavidson/Dotfiles Quick Installation Script
# =============================================================================
# A simplified bootstrap script for quick dotfiles installation
# For advanced options, use the main install.sh script directly
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# =============================================================================
# CONFIGURATION
# =============================================================================

# Nord Color Variables
NORD_BLUE='\033[38;2;94;129;172m'      # #5E81AC - Primary accent
NORD_CYAN='\033[38;2;136;192;208m'     # #88C0D0 - Highlights  
NORD_GREEN='\033[38;2;163;190;140m'    # #A3BE8C - Success
NORD_YELLOW='\033[38;2;235;203;139m'   # #EBCB8B - Warnings
NORD_RED='\033[38;2;191;97;106m'       # #BF616A - Errors
NORD_WHITE='\033[38;2;236;239;244m'    # #ECEFF4 - Light text
NORD_GRAY='\033[38;2;76;86;106m'       # #4C566A - Secondary text
RESET='\033[0m'

# Script Configuration
SCRIPT_NAME="$(basename "$0")"
MAX_RETRIES=3
RETRY_DELAY=2
TIMEOUT=30

# Directory and repository configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/jeffreyDavidson/dotfiles.git}"
PREREQ_URL="https://raw.githubusercontent.com/JeffreyDavidson/dotfiles/refs/heads/main/scripts/installs/prerequisites.sh"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print a formatted banner with optional color
make_banner() {
    local bannerText="$1"
    local lineColor="${2:-$NORD_CYAN}"
    local padding="${3:-0}"
    local titleLen=$((${#bannerText} + 2 + padding))
    local line=""
    
    # Build the line
    for ((i = 0; i < titleLen; i++)); do
        line="${line}─"
    done
    
    local banner="${lineColor}╭${line}╮\n│ ${NORD_WHITE}${bannerText}${lineColor} │\n╰${line}╯"
    echo -e "\n${banner}\n${RESET}"
}

# Print error message and exit
die() {
    make_banner "❌ Error: $1" "$NORD_RED" 2
    exit 1
}

# Print warning message
warn() {
    echo -e "${NORD_YELLOW}⚠️  Warning: $1${RESET}"
}

# Print info message
info() {
    echo -e "${NORD_BLUE}ℹ️  $1${RESET}"
}

# Print success message
success() {
    echo -e "${NORD_GREEN}✅ $1${RESET}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Show progress spinner
show_spinner() {
    local pid=$1
    local message="$2"
    local spinner='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    echo -n "${NORD_BLUE}$message ${RESET}"
    while kill -0 $pid 2>/dev/null; do
        printf "\r${NORD_BLUE}$message ${spinner:$i:1}${RESET}"
        i=$(((i + 1) % ${#spinner}))
        sleep 0.1
    done
    printf "\r${NORD_BLUE}$message ✓${RESET}\n"
}

# Retry function with exponential backoff
retry_command() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local command="$@"
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if eval "$command"; then
            return 0
        else
            if [[ $attempt -lt $max_attempts ]]; then
                warn "Command failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..."
                sleep $delay
                delay=$((delay * 2))  # Exponential backoff
            fi
            ((attempt++))
        fi
    done
    
    return 1
}

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

# Display welcome message and validate environment
show_welcome() {
    make_banner "🧰 JeffreyDavidson/Dotfiles Quick Setup" "$NORD_CYAN" 2
    
    echo -e "${NORD_BLUE}This script will quickly install or update your dotfiles:${RESET}"
    echo -e "${NORD_GRAY}• Repository: ${NORD_WHITE}${DOTFILES_REPO}${RESET}"
    echo -e "${NORD_GRAY}• Destination: ${NORD_WHITE}${DOTFILES_DIR}${RESET}"
    echo -e "${NORD_GRAY}• For advanced options, use ${NORD_WHITE}./install.sh${NORD_GRAY} directly${RESET}"
    echo -e ""
    echo -e "${NORD_YELLOW}Please ensure you've read and understood what will be applied.${RESET}"
    echo -e ""
}

# Validate system requirements and environment
validate_environment() {
    info "Validating system requirements..."
    
    # Check if we're running on a supported system
    if [[ "$(uname)" != "Darwin" && "$(uname)" != "Linux" ]]; then
        die "Unsupported operating system: $(uname)"
    fi
    
    # Validate destination directory path
    if [[ -z "$DOTFILES_DIR" ]]; then
        die "DOTFILES_DIR cannot be empty"
    fi
    
    if [[ "$DOTFILES_DIR" == "/" || "$DOTFILES_DIR" == "$HOME" ]]; then
        die "Invalid DOTFILES_DIR: $DOTFILES_DIR (cannot be root or home directory)"
    fi
    
    # Check for required commands that we need for the bootstrap
    local required_commands=("curl" "mkdir" "chmod")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            die "Required command '$cmd' not found. Please install it and try again."
        fi
    done
    
    # Check internet connectivity
    if ! curl -s --connect-timeout 5 "https://github.com" >/dev/null; then
        die "No internet connection or GitHub is unreachable"
    fi
    
    success "Environment validation complete"
}

# Install prerequisites if git is not available
ensure_git_available() {
    if ! command_exists git; then
        warn "Git not found. Installing prerequisites..."
        
        info "Downloading prerequisite installation script..."
        local prereq_script="/tmp/prerequisites.sh"
        
        if ! retry_command $MAX_RETRIES $RETRY_DELAY "curl -fsSL --connect-timeout $TIMEOUT '$PREREQ_URL' -o '$prereq_script'"; then
            die "Failed to download prerequisites script after $MAX_RETRIES attempts"
        fi
        
        if [[ ! -s "$prereq_script" ]]; then
            die "Downloaded prerequisites script is empty or corrupted"
        fi
        
        info "Running prerequisites installation..."
        if ! bash "$prereq_script" "$@"; then
            die "Prerequisites installation failed"
        fi
        
        # Clean up
        rm -f "$prereq_script"
        
        # Verify git is now available
        if ! command_exists git; then
            die "Git installation failed or git is not in PATH"
        fi
        
        success "Prerequisites installed successfully"
    else
        success "Git is already available"
    fi
}

# Clone or update dotfiles repository
setup_dotfiles_repo() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        info "Cloning dotfiles repository..."
        
        # Create parent directory if it doesn't exist
        local parent_dir="$(dirname "$DOTFILES_DIR")"
        if [[ ! -d "$parent_dir" ]]; then
            mkdir -p "$parent_dir" || die "Failed to create parent directory: $parent_dir"
        fi
        
        # Clone the repository with retry logic
        (
            if ! retry_command $MAX_RETRIES $RETRY_DELAY "git clone --recursive --progress '$DOTFILES_REPO' '$DOTFILES_DIR'"; then
                die "Failed to clone dotfiles repository after $MAX_RETRIES attempts"
            fi
        ) &
        show_spinner $! "Cloning repository"
        wait $!
        
        success "Dotfiles repository cloned successfully"
    else
        info "Dotfiles directory already exists: $DOTFILES_DIR"
        
        # Verify it's actually a git repository
        if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
            die "Directory exists but is not a git repository: $DOTFILES_DIR"
        fi
        
        success "Using existing dotfiles repository"
    fi
}

# Execute the main installation script
run_main_installer() {
    info "Preparing to run main installation script..."
    
    cd "$DOTFILES_DIR" || die "Failed to change to dotfiles directory: $DOTFILES_DIR"
    
    # Verify install.sh exists and is readable
    if [[ ! -f "./install.sh" ]]; then
        die "Main installation script not found: $DOTFILES_DIR/install.sh"
    fi
    
    if [[ ! -r "./install.sh" ]]; then
        die "Main installation script is not readable: $DOTFILES_DIR/install.sh"
    fi
    
    # Make it executable
    chmod +x ./install.sh || die "Failed to make install.sh executable"
    
    info "Launching main installation script..."
    echo -e "${NORD_GRAY}" + "─" * 60 + "${RESET}"
    
    # Execute with all passed parameters, plus --no-clear to preserve our output
    exec ./install.sh --no-clear "$@"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Main function to orchestrate the installation
main() {
    # Handle help flag
    if [[ "$*" == *"--help"* ]] || [[ "$*" == *"-h"* ]]; then
        show_welcome
        echo -e "${NORD_BLUE}Usage:${RESET} $SCRIPT_NAME [options]"
        echo -e ""
        echo -e "${NORD_BLUE}This script will:${RESET}"
        echo -e "  1. Validate system requirements"
        echo -e "  2. Install git if not present"
        echo -e "  3. Clone/update dotfiles repository"
        echo -e "  4. Execute the main install.sh script"
        echo -e ""
        echo -e "${NORD_BLUE}Environment Variables:${RESET}"
        echo -e "  DOTFILES_DIR    Target directory (default: $HOME/dotfiles)"
        echo -e "  DOTFILES_REPO   Repository URL (default: github.com/jeffreyDavidson/dotfiles.git)"
        echo -e ""
        echo -e "${NORD_BLUE}Options:${RESET}"
        echo -e "  --help, -h      Show this help message"
        echo -e "  All other options are passed to install.sh"
        echo -e ""
        echo -e "${NORD_BLUE}Examples:${RESET}"
        echo -e "  $SCRIPT_NAME                    # Interactive installation"
        echo -e "  $SCRIPT_NAME --auto-yes         # Non-interactive installation"
        echo -e "  DOTFILES_DIR=~/my-config $SCRIPT_NAME  # Custom directory"
        exit 0
    fi
    
    # Trap errors to provide better error messages
    trap 'die "Script failed unexpectedly. Check the output above for details."' ERR
    
    # Start the installation process
    show_welcome
    validate_environment
    ensure_git_available "$@"
    setup_dotfiles_repo
    run_main_installer "$@"
}

# Run main function with all arguments
main "$@"

# EOF
