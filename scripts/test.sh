#!/bin/bash

# the system which needs to be tested
SYSTEM=""

# get the system arg or error if it was not provided
if [ "$#" -gt 0 ]; then
    SYSTEM="$1"
else
    echo -e "Usage: $(basename \$0) <system>"
    exit 1
fi

# build the vm for the system
# shellcheck disable=SC2086
nixos-rebuild build-vm --flake path:./#$SYSTEM --no-reexec

# run the vm
exec "result/bin/run-$SYSTEM-vm"
