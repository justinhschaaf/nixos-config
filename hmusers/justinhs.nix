{ inputs, config, pkgs, ... }:

{
    # Import default configs so flakes know how to behave by default
    imports = [
        inputs.flatpaks.homeManagerModules.default
        ../hmmodules/hyprland.nix
        ../hmmodules/terminal.nix
    ];

    # Personal info and the home path to manage
    home.username = "justinhs";
    home.homeDirectory = "/home/justinhs";

    # User-specific packages. I usually like having them at the system level.
    #home.packages = with pkgs; []; # Terminal toys moved to hmmodules/terminal.nix

    # Flatpak config
    services.flatpak = {

        # Add repo
        remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        packages = [
            "flathub:app/com.bitwarden.desktop//stable"
            "flathub:app/com.github.PintaProject.Pinta//stable"
            "flathub:app/com.github.marktext.marktext//stable"
            "flathub:app/com.obsproject.Studio//stable"
            "flathub:app/dev.geopjr.Collision//stable"
            "flathub:app/dev.krtirtho.Flemozi//stable"
            "flathub:app/im.riot.Riot//stable"
            "flathub:app/io.github.spacingbat3.webcord//stable"
            "flathub:app/org.inkscape.Inkscape//stable"
            "flathub:app/org.libreoffice.LibreOffice//stable"
            "flathub:app/org.mozilla.Thunderbird//stable"
            "flathub:app/org.signal.Signal//stable"
            "flathub:app/org.tenacityaudio.Tenacity//stable"
            "flathub:app/org.torproject.torbrowser-launcher//stable"
            "flathub:app/us.zoom.Zoom//stable"
        ];

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
