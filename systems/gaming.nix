{ inputs, lib, config, pkgs, ... }: {

    imports = [ ./gaming-hardware.nix ];

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
    js.desktop.hyprland.screenshot.output = ~/the_shit/Pictures/Screenshots;
    js.desktop.input.jp = true;

    # Enable NVIDIA GPU support and thunderbolt
    js.hardware.nvidia.enable = true;
    services.hardware.bolt.enable = true;

    # Enable apps
    js.programs.dev.enable = true;
    js.programs.gaming.enable = true;
    js.programs.thunar.enable = true;

    # Add Files
    # WARNING: IF EVER CHANGING THE MOUNTPOINT, PLEASE
    # UPDATE THE SYMLINK DEFINED IN THE JUSTINHS HM USERS FILE
    fileSystems."/home/justinhs/the_shit" = {
        device = "/dev/sda1";
        fsType = "ntfs";
        label = "LITTLEBOY"; # context: the 8TB is FATMAN
        options = [ # https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows#editing-fstab
            "uid=1000"
            "gid=100"
            "rw"
            "user"
            "exec"
            "umask=000"
        ];
    };

    # Set system name
    networking.hostName = "bucatini";

}
