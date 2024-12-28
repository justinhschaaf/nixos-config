{ inputs, lib, osConfig, config, pkgs, ... }: {

    options = {
        js.hm.theme.enable = lib.mkOption { default = osConfig.js.desktop.enable; };
    };

    config = lib.mkIf config.js.hm.theme.enable {

        # Dark theme can be forced on stubborn GTK apps by launching them with GTK_THEME=Adwaita:dark

        # Cursor
        # TODO - LONG TERM https://wiki.hyprland.org/Hypr-Ecosystem/hyprcursor/
        home.pointerCursor = {
            package = pkgs.posy-cursors;
            name = "Posy_Cursor_Black";
        };

        # Icons
        gtk = {
            enable = true;
            iconTheme.package = pkgs.nordzy-icon-theme;
            iconTheme.name = "Nordzy-dark";
        };

        # Tell GNOME to use dark mode
        # https://wiki.nixos.org/wiki/GNOME#Dark_mode
        dconf = {
            enable = true;
            settings."org/gnome/desktop/interface".gtk-theme = "Adwaita-dark";
            settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
        };

        # Enable Adwaita style for QT applications
        # https://wiki.nixos.org/wiki/KDE#GNOME_desktop_integration
        qt = {
            enable = true;
            platformTheme.name = "adwaita";
            style.name = "adwaita-dark";
        };

        # Theme Fcitx5
        home.file.".config/fcitx5/conf/classicui.conf" = lib.mkIf osConfig.js.desktop.input.jp {
            text = ''
                # Set Fonts
                Font="Sans Serif 10"
                MenuFont="Sans Serif 10"
                TrayFont="Sans Serif Bold 10"

                # Set Nord themes
                Theme=Nord-Light
                DarkTheme=Nord-Dark

                # Respect system dark theme and accent colors
                UseDarkTheme=True
                UseAccentColor=True

                # Enable Wayland Fractional Scaling
                EnableFractionalScale=True
                '';
        };

    };

}

