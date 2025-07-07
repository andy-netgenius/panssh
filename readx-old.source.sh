#!/usr/bin/env bash
# readx — drop-in replacement for `read -e -r`, with custom tab-complete logic.
# Use as: source <path-to>/readx.source.sh

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || {
  echo "This script should be sourced, not executed." >&2
  exit 1
}

# Example override function for file/dir completion
_readx_complete_filedir() {
  local cur
  _get_comp_words_by_ref -n : cur
  COMPREPLY=( $(compgen -W "mock1.txt mock2.log mockdir/" -- "$cur") )
}

# Overrides existing `complete -F` entries with _readx_complete_* if available
_readx_override_completions() {
  local line func cmd override_func
  while IFS= read -r line; do
    if [[ "$line" =~ complete\ -F\ ([^[:space:]]+)\ (.+) ]]; then
      func="${BASH_REMATCH[1]}"
      cmd="${BASH_REMATCH[2]}"
      override_func="_readx_complete_${func#_}"
      if declare -F "$override_func" >/dev/null; then
        complete -F "$override_func" "$cmd"
      fi
    fi
  done < <(complete -p)
}

# Ensure bash-completion is sourced (if available)
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
[[ -f ~/.bash_completion ]] && source ~/.bash_completion

# Do the override only once per session
if [[ -z "$_READX_COMPLETIONS_OVERRIDDEN" ]]; then
  _readx_override_completions
  _READX_COMPLETIONS_OVERRIDDEN=1
fi

readx() {
  local prompt var

  if [[ "$1" == "-p" ]]; then
    prompt=$2
    shift 2
  fi

  var=$1
  if [[ -z "$var" ]]; then
    echo "Usage: readx [-p prompt] variable_name" >&2
    return 2
  fi

  # Read input directly in the current shell
  local __readx_input
  bind 'set show-all-if-ambiguous off' 2>/dev/null
  bind '"\t": complete' 2>/dev/null

  if ! read -e -r -p "${prompt}" __readx_input; then
    return 130
  fi

  printf -v "$var" '%s' "$__readx_input"
  return 0
}
