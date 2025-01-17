{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./amd.nix
        ./fingerprint.nix
        ./intel.nix
        ./nvidia.nix
    ];

}

