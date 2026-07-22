{ inputs, config, pkgs, ... }: {

    # Partition disk
    js.disks.enable = true;
    js.disks.device = "/dev/sda";
    js.disks.swap.enable = true;

    # Enable Intel CPU support
    js.hardware.intel.cpu.enable = true;

    # Other hardware options
    boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];

    # Enable autologin, password is weak anyways
    services.greetd.settings.initial_session.command = "${pkgs.kdePackages.plasma-workspace}/libexec/plasma-dbus-run-session-if-needed ${pkgs.kdePackages.plasma-bigscreen}/bin/plasma-bigscreen-wayland";
    services.greetd.settings.initial_session.user = "marco";

    # Enable Plasma Bigscreen
    js.desktop.enable = true;
    js.desktop.plasma-bigscreen.enable = true;

    # Enable Thunar
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "lasagna";

}
