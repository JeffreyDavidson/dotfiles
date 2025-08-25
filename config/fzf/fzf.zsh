# FZF Configuration and Enhanced Key Bindings
# Advanced fuzzy finding with custom integrations

# FZF default options for better UX
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --inline-info
  --preview-window=:hidden
  --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (eza --tree --color=always {} | head -200))'
  --color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88
  --color=fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1
  --color=marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1
  --bind='?:toggle-preview'
  --bind='ctrl-a:select-all'
  --bind='ctrl-y:execute-silent(echo {+} | pbcopy)'
  --bind='ctrl-e:execute(echo {+} | xargs -o vim)'
  --bind='ctrl-v:execute(code {+})'
"

# Use fd for file searching (respects .gitignore)
if command_exists fd; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Enhanced FZF key bindings and functions

# Advanced file search with preview
fzf-file-widget() {
  local selected
  selected=$(fd --type f --hidden --follow --exclude .git | 
    fzf --query="$LBUFFER" \
        --select-1 \
        --exit-0 \
        --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null || echo "Binary file"')
  
  if [[ -n $selected ]]; then
    LBUFFER="${LBUFFER}${selected}"
    local ret=$?
    zle reset-prompt
    return $ret
  fi
}
zle -N fzf-file-widget
bindkey '^T' fzf-file-widget

# Enhanced directory navigation
fzf-cd-widget() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | 
    fzf --query="$LBUFFER" \
        --select-1 \
        --exit-0 \
        --preview 'eza --tree --color=always {} | head -200')
  
  if [[ -n $dir ]]; then
    cd "$dir"
    local ret=$?
    zle reset-prompt
    return $ret
  fi
}
zle -N fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# Git integration functions
fzf-git-branch() {
  local branch
  branch=$(git branch -a | 
    sed 's/^..//' | 
    sed 's/remotes\/origin\///' | 
    sort | 
    uniq | 
    fzf --query="$LBUFFER" \
        --select-1 \
        --exit-0 \
        --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES)
  
  if [[ -n $branch ]]; then
    git checkout "$branch"
    zle reset-prompt
  fi
}
zle -N fzf-git-branch

# Git commit browser
fzf-git-log() {
  local commit
  commit=$(git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" | 
    fzf --ansi \
        --no-sort \
        --reverse \
        --multi \
        --bind 'ctrl-s:toggle-sort' \
        --header 'Press CTRL-S to toggle sort' \
        --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES)
  
  if [[ -n $commit ]]; then
    local hash=$(grep -o "[a-f0-9]\{7,\}" <<< "$commit")
    LBUFFER="${LBUFFER}${hash}"
    zle reset-prompt
  fi
}
zle -N fzf-git-log

# Process finder and killer
fzf-kill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --header='[kill:process]' | awk '{print $2}')
  
  if [[ -n $pid ]]; then
    echo $pid | xargs kill -${1:-9}
    zle reset-prompt
  fi
}
zle -N fzf-kill

# Laravel Herd site selector
fzf-herd() {
  local site
  if command_exists herd; then
    site=$(herd list --format=json 2>/dev/null | jq -r '.[].name' | 
      fzf --height 40% --reverse --border --header="Select Herd Site:" --preview 'herd info {1}')
    
    if [[ -n $site ]]; then
      LBUFFER="${LBUFFER}${site}"
      zle reset-prompt
    fi
  else
    echo "Laravel Herd not installed"
  fi
}
zle -N fzf-herd

# Enhanced history search
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | 
    fzf --query="$LBUFFER" \
        --select-1 \
        --exit-0 \
        --expect=ctrl-r,ctrl-x \
        +m \
        -n2..,.. \
        --tiebreak=index \
        --bind=ctrl-r:toggle-sort \
        --preview 'echo {} | cut -d" " -f3- | head -10' \
        --preview-window=down:3:hidden:wrap \
        --bind='?:toggle-preview') )
  local ret=$?
  
  if [[ -n $selected ]]; then
    local accept=0
    if [[ $selected[1] = ctrl-x ]]; then
      accept=1
      shift selected
    fi
    num=$selected[1]
    if [[ -n $num ]]; then
      zle vi-fetch-history -n $num
      [[ $accept = 0 ]] && zle accept-line
    fi
  fi
  zle reset-prompt
  return $ret
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# Project switcher
fzf-projects() {
  local project
  project=$(find ~/Projects -maxdepth 2 -name ".git" -type d | 
    sed 's|/.git||' | 
    sed "s|$HOME/Projects/||" | 
    fzf --query="$LBUFFER" \
        --select-1 \
        --exit-0 \
        --preview 'ls -la ~/Projects/{}')
  
  if [[ -n $project ]]; then
    cd ~/Projects/$project
    zle reset-prompt
  fi
}
zle -N fzf-projects

# Environment variable browser
fzf-env() {
  local var
  var=$(env | sort | 
    fzf --query="$LBUFFER" \
        --select-1 \
        --exit-0 \
        --preview 'echo {1}' \
        --preview-window=down:1)
  
  if [[ -n $var ]]; then
    LBUFFER="${LBUFFER}${var%%=*}"
    zle reset-prompt
  fi
}
zle -N fzf-env

# Custom key bindings
bindkey '^G^B' fzf-git-branch
bindkey '^G^L' fzf-git-log  
bindkey '^X^K' fzf-kill
bindkey '^X^H' fzf-herd
bindkey '^X^P' fzf-projects
bindkey '^X^E' fzf-env

# Aliases for quick access
alias fb='fzf-git-branch'
alias fl='fzf-git-log'
alias fk='fzf-kill'
alias fh='fzf-herd'
alias fp='fzf-projects'

# FZF completion trigger
export FZF_COMPLETION_TRIGGER='~~'

# Advanced completion for kill command
_fzf_complete_kill() {
  _fzf_complete --multi --reverse --prompt="kill> " -- "$@" < <(
    command ps -eo pid,user,comm -w -w | sed 1d
  )
}

# Enhanced completion for git
_fzf_complete_git() {
  ARGS="$@"
  local branches
  branches=$(git branch -vv --all)
  if [[ $ARGS == 'git co'* ]] || [[ $ARGS == 'git checkout'* ]]; then
    _fzf_complete --reverse --multi -- "$@" < <(
      echo $branches
    )
  fi
}

# Load FZF completions if available
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh