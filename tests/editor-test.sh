#!/usr/bin/env bash

# Fake editor for PanSSH automated tests.

set -e

FILE="$1"
initial_content="Created by automated PanSSH test"
updated_content="Edited by automated PanSSH test"

if [ -z "$FILE" ]; then
    echo "editor-test.sh: No file provided" >&2
    exit 1
fi

# Set initial content, or update existing content.
if [ -f "$FILE" ]; then
    content=$(cat "$FILE")
    # Replace initial content.
    if [[ $content == $initial_content ]]; then
        echo "$updated_content" > "$FILE"
    fi
else
    echo $initial_content > "$FILE"
fi

# Message used by the test script to detect editor exit.
echo "editor exit" >&2
exit 0
