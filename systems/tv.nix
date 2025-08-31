{ inputs, config, pkgs, ... }: {

    # Partition disk
    js.disks.enable = true;
    js.disks.device = "/dev/sda";
    js.disks.esp.size = "512M";

    # Enable Intel CPU support
    js.hardware.intel.cpu.enable = true;

    # Other hardware options
    boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];

    # Enable Hyprland
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;
    js.desktop.hyprland.idle.enable = false;

    # make sure colors are (almost) always warm
    js.desktop.hyprland.sunrise = "12:00";
    js.desktop.hyprland.sunset = "12:01";

    # Enable Thunar
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "lasagna";

}
