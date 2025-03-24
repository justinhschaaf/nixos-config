#!/bin/bash

# Needs to be ran as sudo
# "If you do not have Bash or the GNU Coreutils installed when running this, God help you."
# https://theportalwiki.com/wiki/Announcer_voice_lines#Chamber_06

# Local Config Mode. Will download the config locally and rebuild the system
# from it rather than building from the GitHub repo directly. This has no
# impact on zero-touch mode (-z) which will still fetch its config from GitHub
LOCALCFG=0

# Whether to rebuild the system instead of installing NixOS from scratch
REBUILD=0

# Zero-Touch Mode. Automatically formats the disk before installation
ZEROTOUCH=0

# Local Config Mode: defines where to download the config files to
CFGDIR=""

# The system config to install
SYSTEM=""

# The GitHub repo where the config can be found
REPO="justinhschaaf/nixos-config"

# The flake URI for installation
FLAKE=""

# param = exit code
echo_usage() {

    echo -e "Usage: $(basename \$0) [options] <system>

    Options:
      -l \t download the config to the given folder and build the system from it rather than building from the github repo directly
      -r \t rebuilds the system with this config rather than installing nixos from scratch. only use this if installing to an existing nixos system
      -z \t zero-touch mode. automatically formats the disk before installation. the disk config is always fetched from github, -l only applies when installing
      -h \t prints this message

    Arguments:
      system \t the system config to install"

    exit "$1"

}

format_disk() {
    if [ "$ZEROTOUCH" -gt 0 ]; then
        # shellcheck disable=SC2086
        nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --yes-wipe-all-disks --mode destroy,format,mount --flake $FLAKE
    fi
}

download_config() {
    if [ "$LOCALCFG" -gt 0 ]; then

        # Use the locally installed flake rather than GitHub
        # shellcheck disable=SC2086
        FLAKE=path:"$CFGDIR"\#"$SYSTEM"

        # Remove the old config dir or create it if there isn't one
        rm -rf "$CFGDIR"
        mkdir -pv "$CFGDIR"

        # Clone the repo
        git clone "https://github.com/$REPO" "$CFGDIR"

    fi
}

install_nixos() {
    if [ "$REBUILD" -gt 0 ]; then
        # shellcheck disable=SC2086
        nixos-rebuild --boot --flake $FLAKE
    else
        ulimit -n 1048576
        # shellcheck disable=SC2086
        nixos-install --flake $FLAKE --no-root-passwd
    fi

    echo "Done. Please restart the system to apply changes."
}

# Determine argument flags
# https://linuxconfig.org/bash-script-flags-usage-with-arguments-examples
while getopts "l:rzh?" OPTION; do
    case "$OPTION" in
        l)
            LOCALCFG=1
            CFGDIR="$OPTARG"
            ;;
        r) REBUILD=1 ;;
        z) ZEROTOUCH=1 ;;
        h) echo_usage 0 ;;
        ?) echo_usage 1 ;;
    esac
done
shift "$((OPTIND -1))"

if [ "$#" -gt 0 ]; then
    SYSTEM="$1"
    # shellcheck disable=SC2086
    FLAKE=github:$REPO\#"$SYSTEM"
else
    echo_usage 1
fi

format_disk
download_config
install_nixos

exit 0
