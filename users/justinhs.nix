args@{ inputs, config, pkgs, ... }:

{
    # Import default configs so flakes know how to behave by default
    imports = [ 
        inputs.hyprland.homeManagerModules.default 
        inputs.anyrun.homeManagerModules.default
    ];

    # Personal info and the home path to manage
    home.username = "justinhs";
    home.homeDirectory = "/home/justinhs";

    # User-specific packages. I usually like having them at the system level.
    home.packages = with pkgs; [ blackbox-terminal ];

    # Shell default environment variables
    # https://nix-community.github.io/home-manager/options.html#opt-home.sessionVariables
    home.sessionVariables = {
        EDITOR = "micro";
    };

    # hyprland config imported from file
    wayland.windowManager.hyprland = {
        enable = true;
        # the expression in the file is technically a lambda that needs args
        # so this is how we give it args https://stackoverflow.com/a/58055106
        extraConfig = import ../dotfiles/hypr.nix args; 
    };

    # enable eww and link config location
    programs.eww = {
        enable = true;
        configDir = ../dotfiles/eww;
    };

    programs.anyrun = {

        enable = true;

        config = {
            plugins = [ # Everything except randr, stdin, and dictionary
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libapplications.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libkidex.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/librink.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libshell.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libsymbols.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libtranslate.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libwebsearch.so"
            ];
        };

        # Websearch plugin
        extraConfigFiles."websearch.ron".text = ''
            Config(
                prefix: "?",
                engines: [DuckDuckGo] 
            )
        '';

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
