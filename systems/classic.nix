{ inputs, config, pkgs, ... }: {

    # Partition disk
    js.disks.enable = true;
    js.disks.device = "/dev/sda";
    js.disks.swap.enable = true;

    # Create shared dir for game roms
    # this doesn't work, says option doesn't exist. fml lol
    /*disko.devices.disk.main.content.partitions.root.content.subvolumes."/SHARE" = {
        mountOptions = [
            "compress=zstd"
            "noatime"
            "noacl"
        ];
        mountpoint = "/media";
    };*/

    # Mount shared dir for game roms
    # This is a manually-created btrfs subvolume
    # btrfs create /media/SHARE
    fileSystems."/media/SHARE" = {
        device = "/dev/sda3";
        fsType = "btrfs";
        options = [
            "subvol=media/SHARE"
            "compress=zstd"
            "noatime"
            "noacl"
        ];
    };

    # Enable Intel CPU support
    js.hardware.intel.cpu.enable = true;

    # Other hardware options
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];

    # Enable autologin, password is weak anyways
    services.greetd.settings.initial_session.command = "${pkgs.kdePackages.plasma-workspace}/libexec/plasma-dbus-run-session-if-needed ${pkgs.kdePackages.plasma-bigscreen}/bin/plasma-bigscreen-wayland";
    services.greetd.settings.initial_session.user = "marco";

    # Enable Plasma Bigscreen
    js.desktop.enable = true;
    js.desktop.plasma-bigscreen.enable = true;

    # Enable apps
    js.programs.gaming.enable = true;
    js.programs.thunar.enable = true;
    environment.systemPackages = with pkgs; [ retroarch-full ];

    # Enable SSH
    js.server.ssh.enable = true;
    js.server.ssh.openFirewall = true;

    # Set system name
    networking.hostName = "capellini";

}
