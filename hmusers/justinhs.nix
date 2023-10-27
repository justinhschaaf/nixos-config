{ inputs, config, pkgs, ... }:

{
    # Import default configs so flakes know how to behave by default
    imports = [
        inputs.flatpaks.nixosModules.default
        inputs.anyrun.homeManagerModules.default
        ../hmmodules/hyprland.nix
    ];

    # Personal info and the home path to manage
    home.username = "justinhs";
    home.homeDirectory = "/home/justinhs";

    # User-specific packages. I usually like having them at the system level.
    #home.packages = with pkgs; [ blackbox-terminal ];

    # Flatpak config
    services.flatpak = {

        # Enable and add repo. Not sure if I need this since it's set at the system level
        enable = true;
        remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        packages = [
            "flathub:com.bitwarden.desktop//stable"
            "flathub:com.github.PintaProject.Pinta//stable"
            "flathub:com.github.finefindus.eyedropper//stable"
            "flathub:com.github.marktext.marktext//stable"
            "flathub:com.obsproject.Studio//stable"
            "flathub:dev.geopjr.Collision//stable"
            "flathub:im.riot.Riot//stable"
            "flathub:io.github.spacingbat3.webcord//stable"
            "flathub:it.mijorus.smile//stable"
            "flathub:org.inkscape.Inkscape//stable"
            "flathub:org.libreoffice.LibreOffice//stable"
            "flathub:org.mozilla.Thunderbird//stable"
            "flathub:org.signal.Signal//stable"
            "flathub:org.tenacityaudio.Tenacity//stable"
            "flathub:us.zoom.Zoom//stable"
        ];

    };

    # Shell default environment variables
    # https://nix-community.github.io/home-manager/options.html#opt-home.sessionVariables
    home.sessionVariables = {
        EDITOR = "micro";
    };

    # micro editor config https://github.com/zyedidia/micro/blob/master/runtime/help/options.md
    programs.micro.settings = {
        rmtrailingws = true;
        saveundo = true;
        tabstospaces = true;
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
