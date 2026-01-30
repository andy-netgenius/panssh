#!/usr/bin/env bash

# Print the prompt string as used by the PanSSH script.
# This utility is used by tests. See tests/panssh-test.exp

panssh_prompt() {
    
    # ----- Logic from panssh script interactive() -----

    # Get local colour settings.
    local clr0=$(tput sgr0 2>/dev/null) \
    && local clr1=$(tput setaf 1 2>/dev/null) \
    && local clr2=$(tput setaf 3 2>/dev/null) \
    && local clr3=$(tput setaf 6 2>/dev/null)

    # Escaped prompt used, with readx (bash command line input).
    local prompt_ps1=$( printf \
        "\[${clr1}\]%s\[${clr0}\].\[${clr2}\]%s\[${clr0}\]:\[${clr3}\]%s\[${clr0}\]\$ " \
        "$SITE_NAME" "$ENV_ID" "_CWD_"
    )

    # Get un-escaped prompt, used with `echo` and `read`.
    local tmp=${prompt_ps1//\\[/}
    local prompt=${tmp//\\]/}

    # ----- END From panssh script interactive() -----

    echo "$prompt"
}

SITE_NAME=$1
ENV_ID=$2
CWD=$3

PROMPT=$(panssh_prompt)
echo "${PROMPT/_CWD_/$CWD}"
