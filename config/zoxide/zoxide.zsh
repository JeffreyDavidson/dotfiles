# Zoxide Custom Functions
# Core zoxide init and XDG config are handled in .zshrc and .zshenv
# This file adds convenience functions on top

if command -v zoxide >/dev/null 2>&1; then

  # Interactive mode
  alias cdi='zi'

  # Jump to directory and list contents
  zl() {
    local dir
    if [[ $# -eq 0 ]]; then
      dir=$(zoxide query --list | fzf --height 40% --reverse --border)
      [[ -n $dir ]] && cd "$dir" && eza
    else
      cd "$@" && eza
    fi
  }

  # Jump to directory and open in editor
  ze() {
    local dir
    if [[ $# -eq 0 ]]; then
      dir=$(zoxide query --list | fzf --height 40% --reverse --border)
      [[ -n $dir ]] && cd "$dir" && ${EDITOR:-vim} .
    else
      cd "$@" && ${EDITOR:-vim} .
    fi
  }

  # Jump to directory and open VS Code
  zc() {
    local dir
    if [[ $# -eq 0 ]]; then
      dir=$(zoxide query --list | fzf --height 40% --reverse --border)
      [[ -n $dir ]] && cd "$dir" && code .
    else
      cd "$@" && code .
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
      cd "$selected"
      echo "Switched to project: $(basename "$selected")"
      eza
    fi
  }

fi
