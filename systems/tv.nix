{ inputs, config, pkgs, ... }: {

    # Partition disk
    js.disks.enable = true;
    js.disks.device = "/dev/sda";
    js.disks.swap.enable = true;

    # Enable Intel CPU support
    js.hardware.intel.cpu.enable = true;

    # Other hardware options
    boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];

    # Enable Hyprland
    js.desktop.enable = true;
    js.desktop.plasma-bigscreen.enable = true;

    # Enable Thunar
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "lasagna";

}
