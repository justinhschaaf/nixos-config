{ inputs, config, pkgs, ... }:

{

    home.packages = with pkgs; [
        nordzy-icon-theme
        volantes-cursors
        # quintom-cursor-theme
        # banana-cursor :3
    ];

    # Cursor Theme
    # if Posy's Cursors had a PROPER Linux version I'd probably be using that here
    home.pointerCursor.name = "Volantes Cursors";

    # Icons
    gtk.iconTheme.name = "Nordzy";

    # Tell GNOME to use dark mode
    # https://nixos.wiki/wiki/GNOME#Dark_mode
    dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };

    # Enable Adwaita style for QT applications
    # https://nixos.wiki/wiki/KDE#GNOME_desktop_integration
    qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
    };

}
