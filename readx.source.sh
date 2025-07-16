#!/usr/bin/env bash
# readx - part of panssh.
# Test with: cmd=$(bash --init-file readx.source.sh | tail -n1); echo "cmd: $cmd"

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

  # We handle only -F type.
  [[ "$type" != "-F" ]] && return

  # Use our complete function instead.
  $complete -o filenames -o nospace -o default $type _readx_complete $command
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
  local partial results

  (( COMP_CWORD >= 0 )) && partial="${COMP_WORDS[COMP_CWORD]}"

  if [[ -n "${_READX_PARTIAL_LAST+x}" ]] \
  && [[ "$partial" == "$_READX_PARTIAL_LAST" ]]; then
    # The partial matches the last completion - reuse cached results.
    COMPREPLY=( "${_READX_RESULTS_LAST[@]}" )
  else
    # Use ls -AdLpv1 to list completions (dirs have trailing slashes).
    results=$(_readx_exec "ls -AdLpv1 \"$partial\"* 2>/dev/null")
    COMPREPLY=( $(printf "%s\n" "$results") )

    _READX_PARTIAL_LAST="$partial"
    _READX_RESULTS_LAST=( "${COMPREPLY[@]}" )
  fi
}

# Run the given command on the remote host.
# READX_EXEC, REMOTE_ENV and CWD should be set by the parent script.
_readx_exec() {
    local cmd=$(printf '%q' "export $REMOTE_ENV && cd $CWD && $1")
    eval "$( printf "$READX_EXEC" "$cmd" )"
    return $?
}

# Called via `bind` when ENTER is pressed.
_readx_enter() {
  local status="$?"
  history -s "$READLINE_LINE"
  echo "$READLINE_LINE"
  exit $status 2>/dev/null
}

# Ensure standard completions.
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# Set up our overrides.
_readx_override_completions

# Bind ENTER key to capture input and exit.
bind -x '"\r": _readx_enter'

# Set prompt provided by the parent script.
[[ -n "$READX_PROMPT" ]] && PS1="$READX_PROMPT" || PS1="\$ "
