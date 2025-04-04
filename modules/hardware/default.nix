{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./amd.nix
        ./fingerprint.nix
        ./intel.nix
        ./nvidia.nix
    ];

    config = {

        # Enable hardware graphics acceleration. likely also useful to have on
        # servers for rendering, e.g. VDIs
        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;

    };

}

