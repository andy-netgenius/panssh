#!/usr/bin/env bash
# Fake editor for PanSSH automated tests

set -e

FILE="$1"

if [ -z "$FILE" ]; then
    echo "editor-test.sh: No file provided" >&2
    exit 1
fi

# Show current content
if [ -f "$FILE" ]; then
    cat "$FILE"
else
    echo "[Empty file]"
fi

# Replace content
echo "Edited by automated PanSSH test" >"$FILE"

# Message used by the test script to detect editor exit.
echo "editor exit" >&2
exit 0
