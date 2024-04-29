{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.tui.enable = lib.mkEnableOption "terminal utilities";
    };

    config = lib.mkIf config.js.programs.tui.enable {

        # List packages installed in system profile. To search, run:
        # $ nix search wget
        environment.systemPackages = with pkgs; [

            git
            nix-inspect

            # security tools
            lynis
            vulnix

            # terminal utils
            hyfetch
            micro

            # fish plugins
            fishPlugins.done
            fishPlugins.pisces
            fishPlugins.puffer
            fishPlugins.sponge
            fishPlugins.tide
            
        ];

        # No more nano
        # I'd also like to change the default nix-shell to fish
        # It's theoretically possible, but naturally, I can't get it to work
        # fml https://nixos.org/manual/nix/stable/command-ref/nix-shell.html#environment-variables
        environment.variables.EDITOR = "micro";

        # No more bash https://nixos.wiki/wiki/Fish
        programs.fish.enable = true;
        users.defaultUserShell = pkgs.fish;

        # Enable direnv for easy shells. I have a feeling this is useful for more 
        # than just dev environments, so it goes here instead of the dev.nix module. 
        # It automatically sets up the fish hook too, so no need to do so ourselves.
        programs.direnv.enable = true;

        # Enable nh for better Nix commands
        programs.nh.enable = true;
        programs.nh.flake = "/etc/nixos";

        # Enable nix-index for easier package search
        programs.nix-index = {

            enable = true;

            # These are enabled by default; however, the enabled-by-default
            # programs.command-not-found complains about it, so we disable them
            enableBashIntegration = false;
            enableZshIntegration = false;

        };

        # Enable thefuck for fucking ( ͡° ͜ʖ ͡°)
        # automatically sets up fish integration
        programs.thefuck.enable = true;

        # Enable firmware updater https://nixos.wiki/wiki/Fwupd
        # Firmware updates are actually checked for in the autoupdate module
        services.fwupd.enable = true;

    };

}

