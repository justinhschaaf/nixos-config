{ inputs, lib, osConfig, config, pkgs, ... }: {

    # Personal info and the home path to manage
    home.username = "marco";
    home.homeDirectory = "/home/marco";

    # Flatpak config
    services.flatpak.packages = lib.mkIf osConfig.js.programs.desktop.enable [
        "flathub:app/dev.krtirtho.Flemozi//stable"
        "flathub:app/org.torproject.torbrowser-launcher//stable"
    ];

    # Set Mimetypes. Full list in /usr/share/applications on most OSes
    js.hm.mime = lib.mkIf osConfig.js.programs.desktop.enable {
        enable = true;
        apps = {
            audio = [ "mpv.desktop" ];
            docs = [ "xreader.desktop" ];
            browser = [ "firefox.desktop" ];
            image = [ "org.nomacs.ImageLounge.desktop" ];
            video = [ "mpv.desktop" ];
        };
    };

    ######## Stuff that shouldn't be touched is below this line ########

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.05";

    # Let Home Manager manage itself.
    programs.home-manager.enable = true;

}

