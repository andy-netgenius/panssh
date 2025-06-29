#!/usr/bin/env bash

HISTFILE="/tmp/readx"
START_DIR="$(pwd)"
TMP_OUTPUT=$(mktemp)

# Clean up temp file on exit
trap 'rm -f "$TMP_OUTPUT"' EXIT

while true; do
  CURRENT_DIR="$START_DIR"
  CURRENT_INPUT=""

  while true; do
    echo "Current directory:      $CURRENT_DIR"
    echo "Real current directory: $(realpath $CURRENT_DIR)"
    LISTING="$(ls -1p -- "$CURRENT_DIR")"
    PROMPT="$CURRENT_DIR> "

    ./readx "$HISTFILE" "$PROMPT" "$CURRENT_INPUT" "$LISTING" "$TMP_OUTPUT"
  
    STATUS=$?
    RESULT=$(<"$TMP_OUTPUT")
    echo "Output:"
    echo "$RESULT"
    echo "Result: $RESULT"

    if [[ $STATUS -eq 1 ]]; then
      CURRENT_INPUT="$RESULT"
      CURRENT_DIR="${RESULT%/}"  # keep . or .. as-is
      continue
    fi

    if [[ -d "$CURRENT_DIR/$RESULT" ]]; then
      CURRENT_INPUT=""
      CURRENT_DIR="$CURRENT_DIR/$RESULT"
      continue
    fi

    echo "selected dir/file [$CURRENT_DIR/$RESULT]"
    break
  done
done
