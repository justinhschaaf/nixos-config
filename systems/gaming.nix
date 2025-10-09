{ inputs, lib, config, pkgs, ... }: {

    imports = [ ./gaming-hardware.nix ];

    # configure limine Windows dual boot https://wiki.gentoo.org/wiki/Limine#Dual-booting_with_Windows_in_Limine_.28UEFI.29
    boot.loader.grub.enable = true;
    boot.loader.limine.enable = false;
    boot.loader.limine.extraEntries = ''
    /Windows 10
        protocol: efi
        path: boot():/EFI/Microsoft/bootmgfw.efi
    '';

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
    js.desktop.hyprland.monitors = [
        "DP-1,preferred,0x0,1"
        "DP-2,preferred,1920x0,1"
    ];
    js.desktop.hyprland.screenshot.output = "the_shit/Pictures/Screenshots";
    js.desktop.input.jp = true;

    # Enable Intel CPU support and thunderbolt
    js.hardware.intel.cpu.enable = true;
    services.hardware.bolt.enable = true;

    # Enable AMD GPU support
    js.hardware.amd.gpu.enable = true;

    # Enable apps
    js.programs.dev.enable = true;
    js.programs.gaming.enable = true;
    js.programs.thunar.enable = true;

    # Add Files
    # context: 2TB drive is LITTLEBOY, 8TB is FATMAN
    disko.devices.disk.littleboy = {
        device = "/dev/sda";
        type = "disk";
        content.type = "gpt";
        content.partitions.LITTLEBOY = {
            label = "LITTLEBOY";
            size = "100%";
            content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/home/justinhs/the_shit";
            };
        };
    };

    # Set system name
    networking.hostName = "bucatini";

}
