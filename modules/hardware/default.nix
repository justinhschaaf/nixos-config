{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./amd.nix
        ./fingerprint.nix
        ./intel.nix
        ./nvidia.nix
    ];

    config = {

        # genuinely no idea who tf thought this being disabled was a sane default
        # https://discourse.nixos.org/t/add-loadable-kernel-modules-for-usb-wi-fi/29761/6
        hardware.enableAllFirmware = true;

        # Enable hardware graphics acceleration. likely also useful to have on
        # servers for rendering, e.g. VDIs
        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;

    };

}
