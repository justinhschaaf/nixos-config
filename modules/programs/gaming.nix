{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.gaming.enable = lib.mkEnableOption "gaming applications and optimizations";
    };

    config = lib.mkIf config.js.programs.gaming.enable {

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
            "flathub:app/com.mojang.Minecraft//stable"
            "flathub:app/com.valvesoftware.Steam//stable"
            "flathub:app/fr.handbrake.ghb//stable"
            "flathub:app/net.davidotek.pupgui2//stable"
        ];

    };

}

