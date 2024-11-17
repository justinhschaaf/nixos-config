{ inputs, lib, config, pkgs, system, ... }: {

    imports = [ inputs.comin.nixosModules.comin ];

    options.js.update = {
        enable = lib.mkEnableOption "automatic updates";
        gc.enable = lib.mkOption { default = config.js.update.enable; };
    };

    # Fetch updates from GitHub using comin
    config.services.comin = lib.mkIf config.js.update.enable {
        enable = true;
        remotes = [{
            name = "github";
            url = "https://github.com/justinhschaaf/nixos-config.git";
            poller.period = 300; # update every 5 minutes, don't spam github
        }];
    };

    # Clean up old generations weekly
    # https://github.com/kjhoerr/dotfiles/blob/trunk/.config/nixos/os/upgrade.nix
    # https://github.com/viperML/nh?tab=readme-ov-file#nixos-module
    config.programs.nh.clean = lib.mkIf config.js.update.gc.enable {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 30d";
    };

}

