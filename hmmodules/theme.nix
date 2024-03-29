{ inputs, config, pkgs, ... }:

{

    # Dark theme can be forced on stubborn GTK apps by launching them with GTK_THEME=Adwaita:dark
    # TODO https://wiki.hyprland.org/Hypr-Ecosystem/hyprcursor/

    # Icons
    gtk = {
        enable = true;
        iconTheme.package = pkgs.nordzy-icon-theme;
        iconTheme.name = "Nordzy-dark";
    };

    # Tell GNOME to use dark mode
    # https://nixos.wiki/wiki/GNOME#Dark_mode
    dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".gtk-theme = "Adwaita-dark";
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };

    # Enable Adwaita style for QT applications
    # https://nixos.wiki/wiki/KDE#GNOME_desktop_integration
    qt = {
        enable = true;
        platformTheme = "gnome";
        style.name = "adwaita-dark";
    };

    # Theme Fcitx5
    home.file.".config/fcitx5/conf/classicui.conf".text = ''
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

}
