#!/bin/bash

############################################################
# Initialize variables, check requirements, and print info #
############################################################

# Record start time
start_time=`date +%s`

# Get params
params="$params $*"

# Color variables
PRIMARY_COLOR='\033[1;33m'
ACCENT_COLOR='\033[0;34m'
INFO_COLOR='\033[0;30m'
INFO_COLOR_U='\033[4;30m'
SUCCESS_COLOR='\033[0;32m'
WARN_1='\033[1;31m'
WARN_2='\033[0;31m'
RESET_COLOR='\033[0m'

# Current and total taslks, used for progress updates
current_event=0
total_events=90

if [ ! "$(uname -s)" = "Darwin" ]; then
  echo -e "${PRIMARY_COLOR}Incompatible System${RESET_COLOR}"
  echo -e "${ACCENT_COLOR}This script is specific to Mac OS,\
  and only intended to be run on Darwin-based systems${RESET_COLOR}"
  echo -e "${ACCENT_COLOR}Exiting...${RESET_COLOR}"
  exit 1
fi

if [[ ! $params == *"--skip-intro"* ]]; then
  clear

  # Prints intro message
  echo -e "${PRIMARY_COLOR} MacOS App Preference Script${RESET_COLOR}"
  echo -e "${ACCENT_COLOR}Settings will be applied to the following apps:"
  echo -e " - Finder"
  echo -e " - Safari"
  echo -e " - Mail App"
  echo -e " - Terminal"
  echo -e " - Time Machine"
  echo -e " - Activity Monitor"
  echo -e " - Mac App Store"
  echo -e " - Photos App"
  echo -e " - Messages App"
  echo -e " - Chromium"
  echo -e " - Transmission"
  # Informs user what they're running, and cautions them to read first
  echo -e "\n${INFO_COLOR}You are running ${0} on\
  $(hostname -f | sed -e 's/^[^.]*\.//') as $(id -un)${RESET_COLOR}"
  echo -e "${WARN_1}IMPORTANT:${WARN_2} This script will make changes to your system."
  echo -e "${WARN_2}Ensure that you've read it through before continuing.${RESET_COLOR}"

  # Ask for user confirmation before proceeding (if skip flag isn't passed)
  if [[ ! $params == *"--yes-to-all"* ]]; then
    echo -e "\n${PRIMARY_COLOR}Would you like to proceed? (y/N)${RESET_COLOR}"
    read -t 15 -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${ACCENT_COLOR}\nNo worries, nothing will be applied - feel free to come back another time."
      echo -e "${PRIMARY_COLOR}Exiting...${RESET_COLOR}"
      exit 0
    fi
  fi
fi

# Check have got admin privilages
if [ "$EUID" -ne 0 ]; then
  echo -e "${ACCENT_COLOR}\nElevated permissions are required to adjust system settings."
  echo -e "${PRIMARY_COLOR}Please enter your password...${RESET_COLOR}"
  script_path=$([[ "$0" = /* ]] && echo "$0" || echo "$PWD/${0#./}")
  params="--skip-intro ${params}"
  sudo "$script_path" $params || (
    echo -e "${ACCENT_COLOR}Unable to continue without sudo permissions"
    echo -e "${PRIMARY_COLOR}Exiting...${RESET_COLOR}"
    exit 1
  )
  exit 0
fi

# Helper function to log progress to console
function log_msg () {
  current_event=$(($current_event + 1))
  if [[ ! $params == *"--silent"* ]]; then
    if (("$current_event" < 10 )); then sp='0'; else sp=''; fi
    echo -e "${PRIMARY_COLOR}[${sp}${current_event}/${total_events}] ${ACCENT_COLOR}${1}${INFO_COLOR}"
  fi
}

# Helper function to log section to console
function log_section () {
  if [[ ! $params == *"--silent"* ]]; then
    echo -e "${PRIMARY_COLOR}[INFO ] ${1}${INFO_COLOR}"
  fi
}

echo -e "\n${PRIMARY_COLOR}Starting...${RESET_COLOR}"

###############################################################################
# General                                                                     #
###############################################################################
log_section "General"

log_msg "Disable the sound effects on boot"
sudo nvram SystemAudioVolume=" "

log_msg "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

##########
# Finder #
##########
log_section "Finder"

log_msg "Open new tabs to Home"
defaults write com.apple.finder NewWindowTarget -string "PfHm"

log_msg "Open new windows to file root"
defaults write com.apple.finder NewWindowTargetPath -string "file:///"

log_msg "Show hidden files"
defaults write com.apple.finder AppleShowAllFiles -bool true

log_msg "Show file extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

log_msg "Don't ask before emptying trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

log_msg "View all network locations"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

log_msg "Show the ~/Library folder"
chflags nohidden ~/Library

log_msg "Show the /Volumes folder"
sudo chflags nohidden /Volumes

log_msg "Allow finder to be fully quitted with ⌘ + Q"
defaults write com.apple.finder QuitMenuItem -bool true

log_msg "Show the status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

log_msg "Show the path bar in finder"
defaults write com.apple.finder ShowPathbar -bool true

log_msg "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

log_msg "Expand the General, Open and Privileges file info panes"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

log_msg "Keep directories at top of search results"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

log_msg "Search current directory by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

log_msg "Don't show warning when changing extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

log_msg "Don't add .DS_Store to network drives"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

log_msg "Don't add .DS_Store to USB devices"
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

log_msg "Disable disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

log_msg "Open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

log_msg "Open a new Finder window when a disk is mounted"
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

log_msg "Show item info"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

log_msg "Enable snap-to-grid for icons on the desktop and finder"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

log_msg "Set grid spacing for icons on the desktop and finder"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

log_msg "Set icon size on desktop and in finder"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

###############################################################################
# Time Machine                                                                #
###############################################################################
log_section "Time Machine"

log_msg "Prevent Time Machine prompting to use new drive as backup"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###################
# Apple Mac Store #
###################
log_section "Apple Mac Store"

log_msg "Allow automatic update checks"
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

log_msg "Auto install criticial security updates"
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

log_msg "Enable the debug menu"
defaults write com.apple.appstore ShowDebugMenu -bool true

log_msg "Enable extra dev tools"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

####################
# Apple Photos App #
####################
log_section "Apple Photos App"

log_msg "Prevent Photos from opening automatically when devices are plugged in"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

######################
# Apple Messages App #
######################
log_section "Apple Messages App"

log_msg "Disable automatic emoji substitution"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

log_msg "Disable smart quotes"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

#################################
# Restart affected applications #
#################################
log_section "Finishing Up"
log_msg "Restarting affecting apps"
for app in "Calendar" \
	"Contacts" \
	"Finder" \
	"Messages" \
	"Photos" \
	"iCal"; do
	killall "${app}" &> /dev/null
done

#####################################
# Print finishing message, and exit #
#####################################
echo -e "${PRIMARY_COLOR}\nFinishing...${RESET_COLOR}"
echo -e "${SUCCESS_COLOR}✔ ${current_event}/${total_events} tasks were completed \
succesfully in $((`date +%s`-start_time)) seconds${RESET_COLOR}"
echo -e "\n${PRIMARY_COLOR}         .:'\n     __ :'__\n  .'\`__\`-'__\`\`.\n \
:__________.-'\n :_________:\n  :_________\`-;\n   \`.__.-.__.'\n${RESET_COLOR}"

if [[ ! $params == *"--quick-exit"* ]]; then
  echo -e "${ACCENT_COLOR}Press any key to continue.${RESET_COLOR}"
  read -t 5 -n 1 -s
fi
exit 0
