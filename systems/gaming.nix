{ inputs, lib, config, pkgs, ... }: {

    imports = [ ./gaming-hardware.nix ];

    # Autoupdate. TODO enable me
    #js.autoUpdate.enable = true;
    js.autoUpdate.sendNotif = true;

    # Enable Hyprland and JP keyboard
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;
    js.desktop.input.jp = true;

    # Enable NVIDIA GPU support and thunderbolt
    js.hardware.nvidia.enable = true;
    services.hardware.bolt.enable = true;

    # Enable apps
    js.programs.dev.enable = true;
    js.programs.gaming.enable = true;
    js.programs.thunar.enable = true;

    # Add Files
    fileSystems."/mnt/Files" = {
        device = "/dev/sda1";
        fsType = "ntfs";
        label = "LITTLEBOY"; # context: the 8TB is FATMAN
        options = [
            "uid=1000"
            "gid=1000"
            "rw"
            "user"
            "exec"
            "umask=000"
        ];
    };

    # Set system name
    networking.hostName = "bucatini";

}
