{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.hardware.nvidia.gpu.enable = lib.mkEnableOption "NVIDIA driver support";
    };

    config = lib.mkIf config.js.hardware.nvidia.gpu.enable {

        # Load nvidia drivers
        services.xserver.videoDrivers = [ "nvidia" ];

        # Nvidia setup https://wiki.nixos.org/wiki/Nvidia
        hardware.nvidia = {

            # Modesetting is required.
            modesetting.enable = true;

            # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
            powerManagement.enable = false;
            # Fine-grained power management. Turns off GPU when not in use.
            # Experimental and only works on modern Nvidia GPUs (Turing or newer).
            powerManagement.finegrained = false;

            # Use the NVidia open source kernel module (not to be confused with the
            # independent third-party "nouveau" open source driver).
            # Support is limited to the Turing and later architectures. Full list of
            # supported GPUs is at:
            # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
            # Only available from driver 515.43.04+
            # Do not disable this unless your GPU is unsupported or if you have a good reason to.

            # ^ ignore that, wiki has since updated its recommendation and Hyprland suggests keeping this off too
            open = false;

            # Enable the Nvidia settings menu,
            # accessible via `nvidia-settings`.
            nvidiaSettings = true;

            # Optionally, you may need to select the appropriate driver version for your specific GPU.
            package = config.boot.kernelPackages.nvidiaPackages.stable;

        };

        # Install GPU system monitor
        environment.systemPackages = with pkgs; [
            nvidia-system-monitor-qt
        ];

    };

}

