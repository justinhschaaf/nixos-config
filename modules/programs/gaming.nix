{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.gaming.enable = lib.mkEnableOption "gaming applications and optimizations";
    };

    config = lib.mkIf config.js.programs.gaming.enable {

        # Let Steam play nice with the firewall
        programs.steam.dedicatedServer.openFirewall = true;
        programs.steam.remotePlay.openFirewall = true;

        # System packages. Installing Steam here instead of as a Flatpak because
        # the Flatpak updates drivers based on the system drivers. Upon running
        # a system update, if the system installs new drivers, Flatpak will only
        # see the currently installed drivers and install a version to match
        # those, thus always being out of date.
        environment.systemPackages = with pkgs; [
            davinci-resolve
            ffmpeg
            gamemode
            gamescope
            steam
        # Only install Nvidia system monitor if Nvidia is enabled
        ] ++ lib.optional config.js.desktop.nvidia.enable pkgs.nvidia-system-monitor-qt;

        # Flatpak config
        # According to `flatpak info --show-extensions fr.handbrake.ghb`,
        # Handbrake doesn't depend on Flatpak Nvidia drivers, so it can be here
        services.flatpak.packages = [
            "flathub:app/com.mojang.Minecraft//stable"
            "flathub:app/fr.handbrake.ghb//stable"
            "flathub:app/net.davidotek.pupgui2//stable"
        ];

    };

}

