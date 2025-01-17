{ inputs, config, pkgs, ... }: {

    # Partition disk
    js.disks.enable = true;
    js.disks.device = "/dev/sda";

    # Enable Intel CPU support
    js.hardware.intel.cpu.enable = true;

    # Other hardware options
    boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];

    # Enable Hyprland
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;

    # Enable Thunar
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "lasagna";

}
