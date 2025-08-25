# Security-related aliases and functions

# 1Password CLI aliases (requires 'op' to be installed and configured)
command_exists () {
  hash "$1" 2> /dev/null
}

if command_exists op; then
  # 1Password shortcuts
  alias ops='op signin'
  alias opg='op item get'
  alias opl='op item list'
  alias opv='op vault list'
  
  # Generate secure passwords
  alias genpass='op item create --category=password --title="Generated Password" --generate-password=letters,digits,symbols,32'
  
  # Quick password generation to clipboard
  oppass() {
    if [ -z "$1" ]; then
      echo "Usage: oppass <length> [complexity]"
      echo "Complexity: letters, digits, symbols (default: letters,digits,symbols)"
      return 1
    fi
    local length="$1"
    local complexity="${2:-letters,digits,symbols}"
    op item create --category=password --title="Temp-$(date +%s)" --generate-password="$complexity,$length" --format=json | jq -r '.fields[] | select(.purpose=="PASSWORD") | .value' | pbcopy
    echo "Password copied to clipboard"
  }
  
  # SSH key management with 1Password
  op-ssh() {
    if [ "$1" = "start" ]; then
      echo "Starting 1Password SSH agent..."
      export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    elif [ "$1" = "stop" ]; then
      echo "Stopping 1Password SSH agent..."
      unset SSH_AUTH_SOCK
    elif [ "$1" = "status" ]; then
      if [ -n "$SSH_AUTH_SOCK" ]; then
        echo "1Password SSH agent is active"
        ssh-add -l 2>/dev/null || echo "No keys loaded"
      else
        echo "1Password SSH agent is not active"
      fi
    else
      echo "Usage: op-ssh [start|stop|status]"
    fi
  }
fi

# GPG shortcuts
if command_exists gpg; then
  alias gpg-list='gpg --list-secret-keys --keyid-format LONG'
  alias gpg-export='gpg --armor --export'
  alias gpg-import='gpg --import'
  alias gpg-refresh='gpg --refresh-keys'
  
  # GPG key management
  gpg-backup() {
    if [ -z "$1" ]; then
      echo "Usage: gpg-backup <key-id> [output-dir]"
      return 1
    fi
    local key_id="$1"
    local output_dir="${2:-$HOME/Desktop/gpg-backup-$(date +%Y%m%d)}"
    
    mkdir -p "$output_dir"
    
    # Export public key
    gpg --armor --export "$key_id" > "$output_dir/public-key.asc"
    
    # Export private key
    gpg --armor --export-secret-keys "$key_id" > "$output_dir/private-key.asc"
    
    # Export trust database
    gpg --export-ownertrust > "$output_dir/ownertrust.txt"
    
    echo "GPG keys backed up to: $output_dir"
  }
fi

# SSH key management
if command_exists ssh-keygen; then
  # Generate new SSH key
  ssh-keygen-secure() {
    if [ -z "$1" ]; then
      echo "Usage: ssh-keygen-secure <key-name> [email]"
      return 1
    fi
    local key_name="$1"
    local email="${2:-$(git config user.email)}"
    
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519_$key_name"
    echo "New SSH key generated: $HOME/.ssh/id_ed25519_$key_name"
    echo "Add this to your SSH agent: ssh-add $HOME/.ssh/id_ed25519_$key_name"
  }
  
  # Show SSH key fingerprints
  alias ssh-fingerprints='for key in ~/.ssh/*.pub; do echo "=== $key ==="; ssh-keygen -lf "$key"; done'
  
  # Copy SSH public key to clipboard
  ssh-copy-key() {
    local key_file="$1"
    if [ -z "$key_file" ]; then
      key_file="$HOME/.ssh/id_ed25519.pub"
    fi
    
    if [ -f "$key_file" ]; then
      pbcopy < "$key_file"
      echo "SSH public key copied to clipboard: $key_file"
    else
      echo "Key file not found: $key_file"
    fi
  }
fi

# Security auditing aliases
if command_exists brew; then
  alias brew-audit='brew audit --formula'
  alias brew-vulnerabilities='brew audit --cask --formula --strict --online'
fi

# Network security
alias ports='netstat -tulanp'
alias listening='lsof -i -P -n | grep LISTEN'
alias established='lsof -i -P -n | grep ESTABLISHED'

# System security checks
alias check-sudo='sudo -l'
alias check-crontab='crontab -l'
alias check-login-items='osascript -e "tell application \"System Events\" to get the name of every login item"'

# File permissions and security
alias fix-permissions='find . -type f -exec chmod 644 {} \; && find . -type d -exec chmod 755 {} \;'
alias secure-delete='rm -P'  # Secure delete on macOS

# Password generation (fallback if 1Password CLI not available)
if ! command_exists op; then
  # Generate random password using system tools
  genpass() {
    local length="${1:-16}"
    openssl rand -base64 "$length" | tr -d "=+/" | cut -c1-"$length" | pbcopy
    echo "Random password copied to clipboard"
  }
fi

# Security updates
alias security-update='sudo softwareupdate -ia'