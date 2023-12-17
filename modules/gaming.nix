# UNTESTED

{ inputs, config, pkgs, ... }:

{

    # Enable OpenGL
    hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
    };

    # Load nvidia drivers
    services.xserver.videoDrivers = [ "nvidia" ];

    # Nvidia setup https://nixos.wiki/wiki/Nvidia
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
        open = true;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.stable;

    };

    # Not sure if this applies because homemanager mostly manages hyprland
    programs.hyprland.enableNvidiaPatches = true;

    # Let Steam play nice with the firewall
    programs.steam.dedicatedServer.openFirewall = true;
    programs.steam.remotePlay.openFirewall = true;

    environment.systemPackages = with pkgs; [
        davinci-resolve
        ffmpeg
        gamemode
        gamescope
        nvidia-system-monitor-qt
    ];

    # Flatpak config
    services.flatpak.packages = [
        "flathub:app/com.valvesoftware.Steam//stable"
        "flathub:runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE//stable"
        "flathub:app/com.mojang.Minecraft//stable"
        "flathub:app/fr.romainvigier.zap//stable"
    ];

}
