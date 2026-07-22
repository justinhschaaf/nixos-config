{ inputs, lib, config, pkgs, system, ... }: {

    options.js.desktop.plasma-bigscreen.enable = lib.mkEnableOption "Plasma Bigscreen";

    config = lib.mkIf config.js.desktop.plasma-bigscreen.enable {

        # Plasma Bigscreen depends on pretty much everything for KDE Plasma existing.
        # Therefore, we enable it here, but remove most of the default apps we don't need.
        services.desktopManager.plasma6.enable = true;
        environment.plasma6.excludePackages = with pkgs.kdePackages; [
            ark
            aurorae
            baloo-widgets
            discover
            dolphin
            dolphin-plugins
            elisa
            ffmpegthumbs
            gwenview
            kate
            khelpcenter
            konsole
            krdp
            ktexteditor
            kwin-x11
            okular
        ];

        # Install Plasma Bigscreen
        environment.systemPackages = with pkgs; [
            kdePackages.plasma-bigscreen
        ];

        # KDE Connect is integreated into Bigscreen like Internet Explorer in Windows
        # As such, we have to enable it here
        programs.kdeconnect.enable = true;

        # Remove unwanted KDE sessions in the display manager with lib.mkForce
        # We also have to update the default session as Nix complains "plasma" is no longer a valid option
        services.displayManager.sessionPackages = lib.mkForce [ pkgs.kdePackages.plasma-bigscreen ];
        services.displayManager.defaultSession = lib.mkForce "plasma-bigscreen-wayland";

    };

}

