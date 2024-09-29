{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.gaming.enable = lib.mkEnableOption "gaming applications and optimizations";
    };

    config = lib.mkIf config.js.programs.gaming.enable {

        # Steam settings. Installing Steam here instead of as a Flatpak because
        # the Flatpak updates drivers based on the system drivers. Upon running
        # a system update, if the system installs new drivers, Flatpak will 
        # only see the currently installed drivers and install a version to
        # match those, thus always being out of date.
        programs.steam = {
        
            enable = true;

            # Let Steam use Gamescope by default. This also installs it.
            gamescopeSession.enable = true;
            
            # Let Steam play nice with the firewall
            dedicatedServer.openFirewall = true;
            remotePlay.openFirewall = true;
            
        };

        # Enable gamemode
        programs.gamemode.enable = true;

        # Other system packages
        environment.systemPackages = with pkgs; [
            ffmpeg
            handbrake
            #minecraft # currently broken
            modrinth-app
            olive-editor
            protonup-qt
        ];

    };

}

