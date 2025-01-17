{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.hardware.intel.cpu.enable = lib.mkEnableOption "Intel CPU support";
    };

    config = lib.mkIf config.js.hardware.intel.cpu.enable {
        boot.kernelModules = [ "kvm-intel" ];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}

