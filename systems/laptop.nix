{ inputs, lib, config, pkgs, ... }: {

    imports = [ ./laptop-hardware.nix ];

    # Enable Hyprland and JP keyboard
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;
    js.desktop.input.jp = true;

    # Enable fingerprint reader support
    js.hardware.fingerprint.enable = true;

    # Enable Thunar and dev tools
    js.programs.dev.enable = true;
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "farfalle";

}

