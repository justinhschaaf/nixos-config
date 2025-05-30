# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7fb32b07-b6ca-4fc3-bcdb-04065d253784";
      fsType = "btrfs";
    };

  boot.initrd.luks.devices."cryptos".device = "/dev/disk/by-uuid/a20ef6a2-02ee-42b3-a28d-f8bcdaa847a3";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/64DA-F8A0";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/06aa1cd7-ad9f-4119-a7fb-7db4ad0dd061"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  #networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;
}
