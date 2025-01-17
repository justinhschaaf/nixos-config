{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.hardware.amd.cpu.enable = lib.mkEnableOption "AMD CPU support";
    };

    config = lib.mkIf config.js.hardware.amd.cpu.enable {
        boot.kernelModules = [ "kvm-amd" ];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}

