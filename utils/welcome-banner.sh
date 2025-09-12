#!/bin/bash

# =============================================================================
# 🌞 Welcome Banner with Nord Theme
# =============================================================================
# Displays personalized greeting, system information, and daily details
# Features Nord color theme integration and enhanced system information
# For docs and more info, see: https://github.com/jeffreydavidson/dotfiles
#
# Licensed under MIT (C) Jeffrey Davidson 2024
# =============================================================================

# Nord Color Theme
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
RESET='\033[0m'

# Legacy color variables for compatibility
COLOR_P="$NORD_CYAN"    # Primary color
COLOR_S="$NORD_GRAY"    # Secondary color

# Configuration
WELCOME_SHOW_SYSINFO=${WELCOME_SHOW_SYSINFO:-true}
WELCOME_SHOW_WEATHER=${WELCOME_SHOW_WEATHER:-false}  # Disabled by default (requires external API)
WELCOME_TIMEOUT=${WELCOME_TIMEOUT:-2}

# Print time-based personalized greeting with Nord theme
function welcome_greeting() {
  local hour=$(date +%H)
  hour=$((10#$hour))  # Force decimal interpretation
  
  local greeting_msg
  local time_emoji
  
  # Determine greeting and emoji based on time of day
  if [ $hour -lt 4 ] || [ $hour -gt 22 ]; then
    greeting_msg="Good Night"
    time_emoji="🌙"
  elif [ $hour -lt 12 ]; then
    greeting_msg="Good Morning"
    time_emoji="🌅"
  elif [ $hour -lt 18 ]; then
    greeting_msg="Good Afternoon"
    time_emoji="☀️"
  elif [ $hour -lt 22 ]; then
    greeting_msg="Good Evening"
    time_emoji="🌆"
  else
    greeting_msg="Hello"
    time_emoji="👋"
  fi
  
  local welcome_text="$time_emoji  $greeting_msg, $USER!"
  
  # Use figlet with Nord colors if available, otherwise simple styled text
  if command -v figlet >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1; then
      # Use figlet with lolcat for rainbow effect
      echo "$welcome_text" | figlet | lolcat
    else
      # Use figlet with Nord cyan color
      echo -e "${NORD_CYAN}$(echo "$welcome_text" | figlet)${RESET}"
    fi
  else
    # Simple styled greeting with proper alignment
    local box_width=60
    local content_width=$((box_width - 4))  # 4 chars for borders and padding: │ text │
    local text_length=${#welcome_text}
    local padding_needed=$((content_width - text_length))
    
    # Ensure padding is not negative
    if [[ $padding_needed -lt 0 ]]; then
      padding_needed=0
    fi
    
    # Create the box with consistent width
    local top_border="$(printf '%*s' $((box_width - 2)) '' | tr ' ' '─')"
    local padding_spaces="$(printf '%*s' $padding_needed '')"
    
    echo -e "\n${NORD_CYAN}╭${top_border}╮${RESET}"
    echo -e "${NORD_CYAN}│${RESET} ${NORD_WHITE}$welcome_text${RESET}${padding_spaces} ${NORD_CYAN}│${RESET}"
    echo -e "${NORD_CYAN}╰${top_border}╯${RESET}\n"
  fi
}


# Display system information with enhanced formatting
function welcome_sysinfo() {
  if [[ "$WELCOME_SHOW_SYSINFO" != "true" ]]; then
    return 0
  fi
  
  echo -e "${NORD_BLUE}System Information${RESET}"
  echo -e "${NORD_GRAY}$(printf '%*s' 18 '' | tr ' ' '─')${RESET}"
  
  # Use neofetch if available with Nord-friendly colors
  if command -v neofetch >/dev/null 2>&1; then
    neofetch --shell_version off \
      --disable kernel distro shell resolution de wm wm_theme theme icons term packages \
      --backend off \
      --colors 4 6 4 4 6 4 \
      --color_blocks off \
      --memory_display info \
      --memory_percent on 2>/dev/null
  else
    # Manual system info display
    show_manual_sysinfo
  fi
  echo
}

# Manual system information display (fallback)
function show_manual_sysinfo() {
  # Operating System
  if [[ -f /etc/os-release ]]; then
    local os_name=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
  elif command -v sw_vers >/dev/null 2>&1; then
    local os_name="macOS $(sw_vers -productVersion)"
  else
    local os_name="$(uname -s) $(uname -r)"
  fi
  echo -e "${NORD_GRAY}🖥️  OS:${RESET} $os_name"
  
  # Hostname
  echo -e "${NORD_GRAY}🏠 Host:${RESET} $(hostname)"
  
  # Uptime
  if command -v uptime >/dev/null 2>&1; then
    local uptime_str=$(uptime | sed 's/.*up \([^,]*\).*/\1/')
    echo -e "${NORD_GRAY}⏰ Uptime:${RESET} $uptime_str"
  fi
  
  # Memory usage (if available)
  if command -v free >/dev/null 2>&1; then
    local mem_info=$(free -h | awk '/^Mem:/ {printf "%.1fG / %.1fG", $3, $2}')
    echo -e "${NORD_GRAY}💾 Memory:${RESET} $mem_info"
  elif [[ "$(uname)" == "Darwin" ]]; then
    local mem_pressure=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print $5}' | tr -d '%')
    if [[ -n "$mem_pressure" ]]; then
      echo -e "${NORD_GRAY}💾 Memory:${RESET} $((100 - mem_pressure))% used"
    fi
  fi
  
  # Shell
  echo -e "${NORD_GRAY}🐚 Shell:${RESET} $(basename "$SHELL")"
  
  # Terminal
  if [[ -n "$TERM_PROGRAM" ]]; then
    echo -e "${NORD_GRAY}📱 Terminal:${RESET} $TERM_PROGRAM"
  elif [[ -n "$TERMINAL_EMULATOR" ]]; then
    echo -e "${NORD_GRAY}📱 Terminal:${RESET} $TERMINAL_EMULATOR"
  fi
}

# Display today's information with enhanced details
function welcome_today() {
  echo -e "${NORD_BLUE}Today's Information${RESET}"
  echo -e "${NORD_GRAY}$(printf '%*s' 19 '' | tr ' ' '─')${RESET}"
  
  # Current date and time
  echo -e "${NORD_GRAY}🗓️  Date:${RESET} $(date '+%A, %B %d, %Y')"
  echo -e "${NORD_GRAY}🕐 Time:${RESET} $(date '+%H:%M:%S %Z')"
  
  # Last login information with error handling
  if command -v last >/dev/null 2>&1; then
    local last_login=$(last -1 "$USER" 2>/dev/null | head -1 | awk 'NR==1 && $1 != "'$USER'" {next} {print $4" "$5" "$6" "$7" on "$2}' 2>/dev/null)
    if [[ -n "$last_login" && "$last_login" != " on " ]]; then
      echo -e "${NORD_GRAY}⏰ Last Login:${RESET} $last_login"
    fi
  fi
  
  # Git status if in a git repository
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local git_branch=$(git branch --show-current 2>/dev/null)
    local git_status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ -n "$git_branch" ]]; then
      echo -e "${NORD_GRAY}🌳 Git Branch:${RESET} $git_branch"
      if [[ "$git_status" -gt 0 ]]; then
        echo -e "${NORD_GRAY}📝 Changes:${RESET} $git_status uncommitted changes"
      else
        echo -e "${NORD_GRAY}✅ Status:${RESET} Working directory clean"
      fi
    fi
  fi
  
  # Development environment info
  show_dev_environment
  
  echo
}

# Show development environment information
function show_dev_environment() {
  local dev_tools=()
  
  # Check for common development tools
  if command -v node >/dev/null 2>&1; then
    dev_tools+=("Node $(node --version 2>/dev/null | sed 's/v//')")
  fi
  
  if command -v php >/dev/null 2>&1; then
    dev_tools+=("PHP $(php --version 2>/dev/null | head -1 | awk '{print $2}' | cut -d'-' -f1)")
  fi
  
  if [[ ${#dev_tools[@]} -gt 0 ]]; then
    echo -e "${NORD_GRAY}🛠️  Dev Tools:${RESET} $(IFS=', '; echo "${dev_tools[*]}")"
  fi
}

# Main welcome function - orchestrates all components
function welcome() {
  # Clear screen if running interactively
  if [[ $- == *i* ]] && [[ -z "${WELCOME_NO_CLEAR}" ]]; then
    clear
  fi
  
  welcome_greeting
  welcome_sysinfo
  welcome_today
  
  # Show a subtle separator
  echo -e "${NORD_GRAY}$(printf '%*s' $(tput cols 2>/dev/null || echo 80) '' | tr ' ' '─')${RESET}"
}

# Determine if file is being run directly or sourced
([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] ||
  [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
    printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] ||
  [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)) && sourced=1 || sourced=0

# If script being called directly run immediately
if [ $sourced -eq 0 ]; then
  welcome $@
fi

# EOF
