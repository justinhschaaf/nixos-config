{ inputs, lib, osConfig, config, pkgs, ... }: {

    # Personal info and the home path to manage
    home.username = "justinhs";
    home.homeDirectory = "/home/justinhs";

    # User-specific packages. I usually like having them at the system level.
    home.packages = with pkgs; [
        collision
        #element-desktop
        inkscape
        libreoffice
        marktext
        obs-studio
        pinta
        signal-desktop
        tenacity
        webcord
    ];

    # Flatpak config
    services.flatpak.packages = lib.mkIf osConfig.js.programs.desktop.enable [
        "flathub:app/com.simplenote.Simplenote//stable"
        "flathub:app/dev.krtirtho.Flemozi//stable"
        "flathub:app/org.torproject.torbrowser-launcher//stable"
    ];

    # Add micro desktop entry
    xdg.desktopEntries."js.micro" = lib.mkIf osConfig.js.programs.desktop.enable {
        type = "Application";
        exec = "kitty micro %F"; # cursed but it actually works
        name = "micro";
        genericName = "Text Editor";
        comment = "Modern and intuitive terminal-based text editor";
        categories = [ "Development" "IDE" "TextEditor" "Utility" ];
        icon = "terminal";
    };

    # Set Mimetypes. Full list in /usr/share/applications on most OSes
    js.hm.mime = lib.mkIf osConfig.js.programs.desktop.enable {
        enable = true;
        apps = {
            audio = [ "mpv.desktop" ];
            docs = [ "xreader.desktop" ];
            browser = [ "firefox.desktop" ];
            image = [ "org.nomacs.ImageLounge.desktop" ];
            text = [ "js.micro.desktop" ];
            video = [ "mpv.desktop" ];
        };
        #override = {
        #    "modrinth" = [ "modrinth-app-handler.desktop" ];
        #};
    };

    # Add Steam compatdata symlink if on gaming system
    # Steam needs these files linked because it really hates NTFS disks
    # This MUST be done on home manager, and it has to be formatted like this because it's stupid
    # https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows#preventing-ntfs-read-errors
    # https://wiki.nixos.org/wiki/Nix_Language:_Tips_%26_Tricks
    # https://discourse.nixos.org/t/how-to-manage-dotfiles-with-home-manager/30576/3
    home.file = lib.mkIf ("${osConfig.system.name}" == "bucatini" && osConfig.js.programs.gaming.enable) {
        "the_shit/Games/Steam/steamapps/compatdata".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.steam/steam/steamapps/compatdata";
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

