#!/bin/bash

# =============================================================================
# Terminal Color Utilities
# =============================================================================
# Utilities for checking terminal color support and displaying color palettes
# Includes Nord theme integration and enhanced color displays
# Licensed under MIT, (C) Jeffrey Davidson 2024
# =============================================================================

# Nord Color Palette
NORD_BLUE='\033[38;2;94;129;172m'      # #5E81AC - Primary accent
NORD_CYAN='\033[38;2;136;192;208m'     # #88C0D0 - Highlights  
NORD_GREEN='\033[38;2;163;190;140m'    # #A3BE8C - Success
NORD_YELLOW='\033[38;2;235;203;139m'   # #EBCB8B - Warnings
NORD_RED='\033[38;2;191;97;106m'       # #BF616A - Errors
NORD_PURPLE='\033[38;2;180;142;173m'   # #B48EAD - Special
NORD_ORANGE='\033[38;2;208;135;112m'   # #D08770 - Secondary
NORD_WHITE='\033[38;2;236;239;244m'    # #ECEFF4 - Light text
NORD_GRAY='\033[38;2;76;86;106m'       # #4C566A - Muted text
NORD_DARK='\033[38;2;46;52;64m'        # #2E3440 - Dark background

# Standard colors
TEXT_COL="$NORD_BLUE"
RESET='\033[0m'

# Outputs the number of colors supported by your terminal emulator
function check_color_support () {
  echo -e "\n${TEXT_COL}Your terminal supports $(tput colors) colors."
}

# Prints main 16 colors
function color_map_16_bit() {
  echo -e "\n${TEXT_COL}16-Bit Palette${RESET}\n"
  local base_colors='40m 41m 42m 43m 44m 45m 46m 47m'
  for BG in $base_colors; do echo -en " \033[$BG       \033[0m"; done; echo
  for BG in $base_colors; do printf " \033[1;30m\033[%b  %b  \033[0m" $BG $BG; done; echo
  for BG in $base_colors; do echo -en " \033[$BG       \033[0m"; done; echo
}

# Prints all 256 supported colors
function color_map_256_bit() {
  echo -e "\n${TEXT_COL}256-Bit Palette${RESET}\n"
  for i in {0..255}; do 
    printf '\e[38;5;%dm%3d ' $i $i
    (((i+3) % 18)) || printf '\e[0m\n'
  done
  echo -e "${RESET}"
}

# Display Nord color palette used in dotfiles
function nord_color_palette() {
  echo -e "\n${TEXT_COL}Nord Color Palette (Used in Dotfiles)${RESET}\n"
  
  # Display Nord colors with their names and hex values
  echo -e "${NORD_BLUE}██████${RESET} Nord Blue     ${NORD_GRAY}#5E81AC - Primary accent${RESET}"
  echo -e "${NORD_CYAN}██████${RESET} Nord Cyan     ${NORD_GRAY}#88C0D0 - Highlights${RESET}"
  echo -e "${NORD_GREEN}██████${RESET} Nord Green    ${NORD_GRAY}#A3BE8C - Success${RESET}"
  echo -e "${NORD_YELLOW}██████${RESET} Nord Yellow   ${NORD_GRAY}#EBCB8B - Warnings${RESET}"
  echo -e "${NORD_RED}██████${RESET} Nord Red      ${NORD_GRAY}#BF616A - Errors${RESET}"
  echo -e "${NORD_PURPLE}██████${RESET} Nord Purple   ${NORD_GRAY}#B48EAD - Special${RESET}"
  echo -e "${NORD_ORANGE}██████${RESET} Nord Orange   ${NORD_GRAY}#D08770 - Secondary${RESET}"
  echo -e "${NORD_WHITE}██████${RESET} Nord White    ${NORD_GRAY}#ECEFF4 - Light text${RESET}"
  echo -e "${NORD_GRAY}██████${RESET} Nord Gray     ${NORD_GRAY}#4C566A - Muted text${RESET}"
  echo -e "${NORD_DARK}██████${RESET} Nord Dark     ${NORD_GRAY}#2E3440 - Dark background${RESET}"
  echo
}

# Executes Python script by @grawity for interactively selecting colors
function color_chooser() {
  echo -e "${TEXT_COL}Launching interactive color chooser...${RESET}\n"
  
  # Check if python3 is available
  if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${NORD_RED}Error: python3 is required for the color chooser${RESET}"
    return 1
  fi
  
  # Check internet connectivity
  if ! curl -s --connect-timeout 5 "https://github.com" >/dev/null; then
    echo -e "${NORD_RED}Error: Internet connection required for color chooser${RESET}"
    return 1
  fi
  
  curl -s https://raw.githubusercontent.com/grawity/code/master/term/xterm-color-chooser | python3
}

# Determine if file is being run directly or sourced
([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] ||
  [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
    printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] ||
  [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)) && sourced=1 || sourced=0

# If script being called directly run immediately, otherwise register aliases
if [ $sourced -eq 0 ]; then
  check_color_support
  nord_color_palette
  color_map_16_bit
  color_map_256_bit
else
  alias color-map-16="color_map_16_bit"
  alias color-map-256="color_map_256_bit"
  alias color-map="nord_color_palette && color_map_16_bit && color_map_256_bit"
  alias color-support="check_color_support"
  alias nord-colors="nord_color_palette"
  alias color-chooser="color_chooser"
fi
