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
            parted
            patool # zip util
            sops

            # fish plugins
            fishPlugins.pisces
            fishPlugins.puffer
            fishPlugins.tide

        ];

        # No more nano
        # I'd also like to change the default nix-shell to fish
        # It's theoretically possible, but naturally, I can't get it to work
        # fml https://nixos.org/manual/nix/stable/command-ref/nix-shell.html#environment-variables
        environment.variables.EDITOR = "micro";

        # No more bash https://wiki.nixos.org/wiki/Fish
        programs.fish.enable = true;
        users.defaultUserShell = pkgs.fish;

        # Init prompt and get rid of MOTD
        # https://fishshell.com/docs/current/cmds/fish_greeting.html
        programs.fish.interactiveShellInit = ''
            tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time='24-hour format' --lean_prompt_height='One line' --prompt_spacing=Compact --icons='Few icons' --transient=Yes
            set -U tide_cmd_duration_color brwhite
            set -U tide_time_color brwhite
            set -U fish_greeting
        '';

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

        # Enable tmux terminal multiplexer
        programs.tmux = {
            enable = true;
            clock24 = true;
            shortcut = "a";
            terminal = "screen-256color";
            extraConfig = ''
                set -g mouse on
                set -g history-limit 2000
            '';
        };

        # Enable firmware updater https://wiki.nixos.org/wiki/Fwupd
        # Firmware updates are actually checked for in the autoupdate module
        services.fwupd.enable = true;

    };

}

