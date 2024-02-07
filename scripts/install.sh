#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git
# https://nixos.org/manual/nix/stable/command-ref/nix-shell.html#use-as-a--interpreter

# Needs to be ran as sudo unless your CFGDIR is in userspace
# "If you do not have Bash or the GNU Coreutils installed when running this, God help you."
# https://theportalwiki.com/wiki/Announcer_voice_lines#Chamber_06

CFGDIR="/etc/nixos/"

if [ "$#" -gt 0 ]; then
    CFGDIR="$1"
fi

readonly HARDCONF="$CFGDIR"hardware-configuration.nix

# https://linuxize.com/post/bash-check-if-file-exists/
# https://www.shellcheck.net/wiki/SC2155
HARDCONFEXISTS=$(test -f "$HARDCONF")
readonly HARDCONFEXISTS

if "$HARDCONFEXISTS"; then
    # Make sure temp dir exists before moving there
    mkdir -pv /tmp
    mv "$HARDCONF" /tmp/
fi

rm -rf "$CFGDIR"

git clone https://github.com/justinhschaaf/nixos-config "$CFGDIR"

if "$HARDCONFEXISTS"; then
    mv /tmp/hardware-configuration.nix "$CFGDIR"
fi
