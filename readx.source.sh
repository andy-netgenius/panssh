#!/usr/bin/env bash
# readx - part of panssh.
# Test with: cmd=$(bash --init-file readx.source.sh | tail -n1) && echo "cmd: $cmd"

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || {
  echo "This script should not be executed directly." >&2
  exit 1
}

# Override a completion.
_readx_override_completion() {
  local args=("$@")
  local len=${#args[@]}

  # Split complete+options from the key parameters. 
  local complete=("${args[@]:0:len-3}")
  local type="${args[$((len - 3))]}"
  local function="${args[$((len - 2))]}"
  local command="${args[$((len - 1))]}"

  # We handle only -F type for given commands.
  ( [[ "$type" != "-F" ]] || [[ "$command" == "''" ]] ) && return

  # Use our complete function instead.
  # Note adding -o bashdefault may help?
  $complete -o bashdefault -o nospace -o default $type _readx_complete $command 

  # Try this if above isn't working.
  #complete -o bashdefault -o default $type _readx_complete "$command"
}

# Loop through existing completions and override them.
_readx_override_completions() {
  local line
  while IFS= read -r line; do
    _readx_override_completion $line
  done < <(complete -p)
}

# File and directory name completion.
_readx_complete() {
  # We use ls -AdLp1 instead of compgen - easier to detect directory vs file.
  local partial="${COMP_WORDS[COMP_CWORD]}"
  local results=$(_readx_exec "ls -AdLp1 \"$partial\"* 2>/dev/null")
  COMPREPLY=( $(printf "%s\n" $results) )
}

# Run the given command remotely and echo the output.
_readx_exec() {
  _readx_ssh_exec "export $REMOTE_ENV && cd $CWD && $1"
}

# --- SSH wrapper ---
_readx_ssh_exec() {
    local cmd=$(printf '%q' "$1")
    ssh $SSH_OPTIONS "$USER@$HOST" "echo $cmd | bash; exit \${PIPESTATUS[1]}"
    return $?
}

_readx_capture_enter() {
  local status="$?"

  # Remove leading and trailing whitespace from the input line.
  trimmed="${READLINE_LINE#"${READLINE_LINE%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

  # Add to history.
  [[ -n "$trimmed" ]] && history -s "$trimmed"

  echo "$READLINE_LINE"
  exit $status 2>/dev/null
}

# Ensure standard completions.
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# Set up our overrides.
_readx_override_completions

# Bind ENTER key to capture input and exit.
bind -x '"\r": _readx_capture_enter' 2>/dev/null

# Set prompt provided by the parent script.
[[ -n "$READX_PROMPT" ]] && PS1="$READX_PROMPT"
