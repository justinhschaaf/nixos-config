#!/bin/bash

CFGDIR="/etc/nixos/"

if [ "$#" -gt 0 ]; then
    CFGDIR="$1"
fi

# https://www.shellcheck.net/wiki/SC2164
cd "$CFGDIR" || { notify-send "Update Failed" "There was a problem navigating to the system config directory."; exit 1; }

# https://www.w3docs.com/snippets/git/how-to-programmatically-determine-if-there-are-uncommitted-changes.html
# https://git-scm.com/docs/git-diff-index
# https://www.cyberciti.biz/faq/bash-get-exit-code-of-command/
if git diff-index --quiet HEAD --; then

    notify-send "Updating System Config" "Please do not shut down your computer."

    git pull --prune
    if [ "$?" -eq 1 ]; then
        notify-send "Update Failed" 'There was a problem pulling the latest config from Git, please run "git pull --prune" manually for more details.'
        exit 1
    fi

    nixos-rebuild boot
    if [ "$?" -eq 1 ]; then
        notify-send "Update Failed" 'There was a problem rebuilding the system, please run "nixos-rebuild boot" manually for more details.'
        exit 1
    fi

    nofity-send "System Config Updated" "The system was successfully rebuilt with the latest config."
    exit 0

else
    notify-send "Update Skipped" "Your system config has unsaved changes. Please resolve all conflicts before attempting to update the system again."
    exit 1
fi
