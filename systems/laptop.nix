{ inputs, lib, config, pkgs, ... }: {

    imports = [ ./laptop-hardware.nix ];

    # Setup disk partitioning
    #js.disks.enable = true;
    js.disks.device = "/dev/nvme0n1";
    js.disks.encrypt = true;
    js.disks.swap.enable = true;
    js.disks.swap.size = "20GiB";

    # Enable Hyprland and JP keyboard
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;
    js.desktop.hyprland.monitors = ",preferred,auto,1.5";
    js.desktop.input.jp = true;

    # Enable fingerprint reader support
    js.hardware.fingerprint.enable = true;

    # Enable Thunar and dev tools
    js.programs.dev.enable = true;
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "farfalle";

}

