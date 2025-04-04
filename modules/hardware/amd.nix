{ inputs, lib, config, pkgs, ... }: {

    options.js.hardware.amd = {
        cpu.enable = lib.mkEnableOption "AMD CPU support";
        gpu.enable = lib.mkEnableOption "AMD GPU support";
    };

    config = lib.mkIf config.js.hardware.amd.cpu.enable {

        boot.kernelModules = [ "kvm-amd" ];
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    } // lib.mkIf config.js.hardware.amd.gpu.enable {
        hardware.amdgpu.initrd.enable = true;

        # Install GPU overclock controller https://wiki.nixos.org/wiki/AMD_GPU#GUI_tools
        environment.systemPackages = with pkgs; [ lact ];
        systemd.packages = with pkgs; [ lact ];
        systemd.services.lactd.wantedBy = ["multi-user.target"];
    };

}

