#!/usr/bin/env bash
# readx - part of panssh.
# Test with: cmd=$(bash --init-file readx.source.sh | tail -n1) && echo "cmd: $cmd"

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || {
  echo "This script should not be executed directly." >&2
  exit 1
}

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

  # echo ">$complete -o default $type _readx_complete $command " >&2
  $complete -o nospace -o default $type _readx_complete $command 

  # Try this if above isn't working.
  #echo ">complete -o bashdefault -o default $type _readx_complete $command" >&2
  #complete -o bashdefault -o default $type _readx_complete "$command"
}

# Read existing completions and override them.
_readx_override_completions() {
  local line
  while IFS= read -r line; do
    _readx_override_completion $line
  done < <(complete -p)
}

_readx_complete() {
  #echo -e "\n--- Intercepted completion ---" >&2 
  #echo "Words: ${words[0]} ${words[1]} ${words[2]} ${words[3]}  cword: $cword" >&2
 
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # Get and return matches.
  #local results=$(compgen -f -- "$cur")
  #local results=$(_readx_exec "compgen -f -- '$cur'")

  # local results=$(_readx_exec "compgen -f -- $cur")
  # local results=$(_readx_compgen "$cur")

  # Using ls -dp1 instead of compgen allows directoires to complete correctly.
  local results=$(_readx_exec "ls -dp1 ${COMP_WORDS[COMP_CWORD]}*")
  
  COMPREPLY=( $(printf "%s\n" $results) )
  
}

_readx_compgen() {
  local cur="$1"
  for match in $(_readx_exec "compgen -f -- $cur"); do
    if _readx_exec "test -d '$match'"; then
      echo "${match}/"
    else
      echo "${match} "
    fi
  done
}

# Run the given command remotely and echo the output.
_readx_exec() {
  # Mock remote simply using local.
  #eval "$1"
  #echo $(eval $1);
  # "$1"
  _readx_ssh_exec "export $REMOTE_ENV && cd $CWD && $1"
}

_readx_capture_enter() {
  local status="$?"
  [[ -n "$READLINE_LINE" ]] && history -s "$READLINE_LINE"

  echo "$READLINE_LINE"
  exit $status 2>/dev/null
}

# --- SSH wrapper ---
_readx_ssh_exec() {
    local cmd=$(printf '%q' "$1")
    ssh $SSH_OPTIONS "$USER@$HOST" "echo $cmd | bash; exit \${PIPESTATUS[1]}"
    return $?
}

# Ensure standard completions.
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# Set up our overrides.
_readx_override_completions

# Bind ENTER key to capture input and exit.
bind -x '"\r": _readx_capture_enter' 2>/dev/null

# Set prompt provided by the parent script.
[[ -n "$READX_PROMPT" ]] && PS1="$READX_PROMPT"

#echo "SSH: $SSH_OPTIONS $USER $HOST" >&2
#_readx_ssh_exec "cd $CWD; pwd && ls" >&2
