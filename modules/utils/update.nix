{ inputs, lib, config, pkgs, system, ... }: {

    imports = [ inputs.comin.nixosModules.comin ];

    options.js.update = {
        enable = lib.mkEnableOption "automatic updates";
        gc.enable = lib.mkEnableOption "weekly garbage collection" // { default = config.js.update.enable; };
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
    config.nix.gc = lib.mkIf config.js.update.gc.enable {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
    };

}
