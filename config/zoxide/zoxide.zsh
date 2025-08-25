# Zoxide Configuration
# Smart directory jumping based on frequency and recency

# Initialize zoxide (replaces cd with z)
if command_exists zoxide; then
  eval "$(zoxide init zsh)"

  # Enhanced aliases for directory navigation
  alias cd='z'
  alias cdi='zi'  # Interactive mode
  alias cdb='z -'  # Go back to previous directory

  # Quick navigation aliases
  alias projects='z ~/Projects'
  alias config='z ~/.config'
  alias docs='z ~/Documents'
  alias downloads='z ~/Downloads'
  alias desktop='z ~/Desktop'

  # Project-specific shortcuts (adjust these to your common projects)
  alias dotfiles='z ~/dotfiles'

  # Advanced zoxide functions

  # Jump to directory and list contents
  zl() {
    local dir
    if [[ $# -eq 0 ]]; then
      dir=$(zoxide query --list | fzf --height 40% --reverse --border)
      [[ -n $dir ]] && z "$dir" && eza
    else
      z "$@" && eza
    fi
  }

  # Jump to directory and open in editor
  ze() {
    local dir
    if [[ $# -eq 0 ]]; then
      dir=$(zoxide query --list | fzf --height 40% --reverse --border)
      [[ -n $dir ]] && cd "$dir" && ${EDITOR:-vim} .
    else
      z "$@" && ${EDITOR:-vim} .
    fi
  }

  # Jump to directory and open VS Code
  zc() {
    local dir
    if [[ $# -eq 0 ]]; then
      dir=$(zoxide query --list | fzf --height 40% --reverse --border)
      [[ -n $dir ]] && cd "$dir" && code .
    else
      z "$@" && code .
    fi
  }

  # Interactive directory removal from zoxide database
  zf() {
    local dir
    dir=$(zoxide query --list | fzf --height 40% --reverse --border)
    if [[ -n $dir ]]; then
      echo "Remove '$dir' from zoxide database? (y/N)"
      read -q && zoxide remove "$dir"
    fi
  }

  # Show zoxide statistics
  zstats() {
    echo "=== Zoxide Database Statistics ==="
    echo "Total entries: $(zoxide query --list | wc -l)"
    echo ""
    echo "Top 10 most frecent directories:"
    zoxide query --list --score | head -10 | while read -r score path; do
      printf "%8.1f  %s\n" "$score" "$path"
    done
    echo ""
    echo "Recent additions:"
    zoxide query --list | tail -5
  }

  # Backup zoxide database
  zbackup() {
    local backup_file="$HOME/zoxide-backup-$(date +%Y%m%d-%H%M%S).txt"
    zoxide query --list > "$backup_file"
    echo "Zoxide database backed up to: $backup_file"
  }

  # Restore zoxide database from backup
  zrestore() {
    if [[ -z "$1" ]]; then
      echo "Usage: zrestore <backup-file>"
      return 1
    fi

    if [[ ! -f "$1" ]]; then
      echo "Backup file not found: $1"
      return 1
    fi

    echo "This will replace your current zoxide database. Continue? (y/N)"
    read -q || return 0

    # Clear current database
    rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/zoxide/db.zo"

    # Add paths from backup
    while IFS= read -r path; do
      [[ -d "$path" ]] && zoxide add "$path"
    done < "$1"

    echo "Zoxide database restored from: $1"
  }

  # Smart project switcher with zoxide integration
  zproject() {
    local project_dirs=(
      "$HOME/Projects"
      "$HOME/Herd"
    )

    local projects=()
    for dir in "${project_dirs[@]}"; do
      [[ -d "$dir" ]] && projects+=($(find "$dir" -maxdepth 2 -name ".git" -type d | sed 's|/.git||'))
    done

    if [[ ${#projects[@]} -eq 0 ]]; then
      echo "No git projects found in common directories"
      return 1
    fi

    local selected
    selected=$(printf '%s\n' "${projects[@]}" |
      fzf --height 40% \
          --reverse \
          --border \
          --preview 'ls -la {}' \
          --preview-window=right:50%)

    if [[ -n "$selected" ]]; then
      z "$selected"
      echo "Switched to project: $(basename "$selected")"
      eza
    fi
  }

  # Export zoxide data directory for XDG compliance
  export _ZO_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zoxide"

  # Create data directory if it doesn't exist
  [[ ! -d "$_ZO_DATA_DIR" ]] && mkdir -p "$_ZO_DATA_DIR"

else
  echo "Zoxide not installed. Install with: brew install zoxide"
fi
