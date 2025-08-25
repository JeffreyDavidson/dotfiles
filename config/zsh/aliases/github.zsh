# Minimal GitHub CLI Setup
# Essential backup commands for when GitKraken isn't available

# Essential Git shortcuts (work everywhere)
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main'
alias gcd='git checkout develop'
alias gpu='git push -u origin HEAD'
alias gpl='git pull'
alias glog='git log --oneline --graph --decorate --all -10'

# Check if GitHub CLI is available
if command_exists gh; then
    
    # Essential GitHub CLI shortcuts (minimal set)
    alias ghpr='gh pr list'                    # Quick PR overview
    alias ghpro='gh pr view --web'             # Open PR in browser (back to GUI!)
    alias ghio='gh issue view --web'           # Open issue in browser
    alias ghas='gh auth status'                # Check auth status
    
    # Simple clone function (faster than copying URLs)
    ghclone() {
        if [[ -z "$1" ]]; then
            echo "Usage: ghclone <user/repo>"
            return 1
        fi
        gh repo clone "$1"
    }
    
    # Quick repo browser opener
    ghopen() {
        gh repo view --web
    }
    
    # Emergency PR creation (when GitKraken fails)
    ghprquick() {
        local title="$1"
        if [[ -z "$title" ]]; then
            echo "Usage: ghprquick <title>"
            return 1
        fi
        gh pr create --title "$title" --body "Created via CLI" --web
    }
    
else
    echo "GitHub CLI not installed. Run: brew install gh"
    echo "(Optional backup for when GitKraken isn't available)"
fi