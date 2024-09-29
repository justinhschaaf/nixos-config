#!/bin/bash

# Define Vars

# https://stackoverflow.com/questions/39296472/how-to-check-if-an-environment-variable-exists-and-get-its-value
CONFIG_DIR="${FLAKE:-/etc/nixos}"

REBUILD_CMD="boot";

SEND=true;
SEND_NOTIF=false;
SEND_EMAIL=false;

UPDATE_CONFIG=false;
CHECK_FIRMWARE=false;

# Define Functions https://linuxize.com/post/bash-functions/

# param = exit code
echo_usage() {

    echo -e "Usage: $(basename \$0) [options] <config>

    Options:
      -c \t whether to fetch the latest config and rebuild the system
      -r \t the rebuild command to use, either \"boot\" (default), \"switch\", or \"test\"
      -f \t whether to check for firmware updates and notify if there are any
      -n \t whether to send important messages via notification
      -e \t whether to send important messages via email (not implemented)
      -h \t prints this message

    Arguments:
      config \t (optional) the folder path to where the system's NixOS config is stored"

    exit $1

}

# args: short version, full message
send_msg() {

    if [ "$SEND" = true ]; then
        echo "[$(basename \$0)] $1: $2"
    fi

    if [ "$SEND_NOTIF" = true ]; then
        notify-send $1 $2
    fi

    if [ "$SEND_EMAIL" = true ]; then
        # not implemented https://www.digitalocean.com/community/tutorials/send-email-linux-command-line
    fi

}

# Update the system configuration if we're supposed to and able to. No args.
update_system_config() {

    if [ "$UPDATE_CONFIG" = true ]; then

        # https://www.shellcheck.net/wiki/SC2164
        cd "$CONFIG_DIR" || { send_msg "Config Update Failed" "There was a problem navigating to the system config directory."; return 1; }

        # https://www.w3docs.com/snippets/git/how-to-programmatically-determine-if-there-are-uncommitted-changes.html
        # https://git-scm.com/docs/git-diff-index
        # https://www.cyberciti.biz/faq/bash-get-exit-code-of-command/
        git diff-index --quiet HEAD --
        if [ "$?" -eq 0 ]; then

            # We have no unsaved changes, proceed with the update
            send_msg "Updating System Config" "Please do not shut down your computer."

            # Fetch the latest changes from Git
            git pull --prune
            if [ "$?" -eq 1 ]; then
                send_msg "Config Update Failed" 'There was a problem pulling the latest config from Git, please run "git pull --prune" manually for more details.'
                return 1
            fi

            # Rebuild the system with nh, disabling NOM for cleaner logs
            # IN CASE WE HAVE PROBLEMS: https://discourse.nixos.org/t/dirty-nixos-rebuild-build-flake-issues/30078/2
            nh os $REBUILD_CMD --no-nom "path:$CONFIG_DIR"
            if [ "$?" -eq 1 ]; then
                send_msg "Config Update Failed" 'There was a problem rebuilding the system, please run "nh os $REBUILD_CMD" manually for more details.'
                return 1
            fi

            send_msg "System Config Updated" "The system was successfully rebuilt with the latest config."
            return 0

        else
            send_msg "Config Update Skipped" "Your system config has unsaved changes. Please resolve all conflicts before attempting to update the system again."
            return 1
        fi

    fi

}

# no args, returns 2 if firmware updates are available
check_firmware() {

    if [ "$CHECK_FIRMWARE" = true ]; then

        # Refresh the repo and check for updates. Returns exit code 2 if there are none
        fwupdmgr refresh --force
        fwupdmgr get-updates

        local FWUPDMGR_STATUS="$?"
        if [ "$FWUPDMGR_STATUS" -eq 0 ]; then
            send_msg "Firmware Updates Available" 'Please run "fwupdmgr update" the next time your device is plugged in.'
            return 2
        else if [ "$FWUPDMGR_STATUS" -eq 1 ];
            send_msg "Firmware Check Failed" 'There was a problem checking for firmware updates, please run "fwupdmgr get-updates" manually for more details.'
            return 1
        fi

        # No updates
        return 0

    fi

}

# Determine argument flags
# https://linuxconfig.org/bash-script-flags-usage-with-arguments-examples
while getopts "ab:-:" OPTION; do
    case "$OPTION" in
        c) UPDATE_CONFIG=true ;;
        r) REBUILD_CMD="$OPTARG" ;;
        f) CHECK_FIRMWARE=true ;;
        n) SEND_NOTIF=true ;;
        e) SEND_EMAIL=true ;;
        h) echo_usage 0 ;;
        ?) echo_usage 1 ;;
    esac
done
shift "$(($OPTIND -1))"

if [ "$#" -gt 0 ]; then
    CONFIG_DIR="$1"
fi

update_system_config
EXIT_SYSTEM_CONFIG="$?"

check_firmware
EXIT_CHECK_FIRMWARE="$?"

if [ "$EXIT_SYSTEM_CONFIG" -eq 1 ]; then
    exit 1
else
    exit "$EXIT_CHECK_FIRMWARE"
fi

