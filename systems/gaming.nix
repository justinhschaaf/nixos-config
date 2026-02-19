{ inputs, lib, config, pkgs, ... }: {

    # automatic drive partitioning
    js.disks = {
        enable = true;
        device = "/dev/nvme0n1";
        encrypt = true;
        swap.enable = true;
        swap.size = "32G";
    };

    # configure limine Windows dual boot https://wiki.gentoo.org/wiki/Limine#Dual-booting_with_Windows_in_Limine_.28UEFI.29
    boot.loader.grub.enable = true;
    boot.loader.limine.enable = false;

    js.backup = {
        enable = true;
        src = /home/justinhs/the_shit;
        dest = /mnt/FATLIN/LITTLEBOY_BACKUPS/rsync;
        keep = 28;
        mount = {
            enable = true;
            device = "/dev/sdb2";
            dir = "/mnt/FATLIN";
        };
        excludes = [
            "Games/Steam/steamapps"
            ".Trash-1000"
            "'$RECYCLE.BIN'"
            "/.*" # exclude all dotfiles in the home dir, these are managed by home manager, not important to back up
        ];
    };

    # Enable Hyprland and JP keyboard
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;
    js.desktop.hyprland.idle.enable = false;
    js.desktop.hyprland.screenshot.output = "the_shit/Pictures/Screenshots";
    js.desktop.input.jp = true;

    # Hyprland overrides
    programs.hyprland.settings.general.layout = "master";
    programs.hyprland.settings.master.orientation = "center";
    programs.hyprland.settings.master.mfact = 0.5;
    programs.hyprland.settings.dwindle.single_window_aspect_ratio = "16 10";

    # Enable Intel CPU support and thunderbolt
    js.hardware.intel.cpu.enable = true;
    services.hardware.bolt.enable = true;

    # Enable AMD GPU support
    js.hardware.amd.gpu.enable = true;

    # Enable apps
    js.programs.dev.enable = true;
    js.programs.gaming.enable = true;
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "bucatini";

}
