#!/usr/bin/env bash
# Fake editor for PanSSH automated tests

set -e

FILE="$1"

if [ -z "$FILE" ]; then
    echo "editor-test.sh: No file provided" >&2
    exit 1
fi

echo "--- BEGIN ORIGINAL CONTENTS ($FILE) ---" >&2
if [ -f "$FILE" ]; then
    cat "$FILE"
else
    echo "[File does not exist yet]" >&2
fi
echo "--- END ORIGINAL CONTENTS ---" >&2

echo "Overwriting file with test content..."

# Replace contents with predictable text
echo "Edited by automated PanSSH test" >"$FILE"

# Message used by the test script to detect editor exit.
echo "$(basename $0) exit" >&2
exit 0
