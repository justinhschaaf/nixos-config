{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.autoUpdate.enable = lib.mkEnableOption "automatic updates";
        js.autoUpdate.firmware = lib.mkOption { default = config.js.autoUpdate.enable; };
        js.autoUpdate.gc = lib.mkOption { default = config.js.autoUpdate.enable; };
        js.autoUpdate.system = lib.mkOption { default = config.js.autoUpdate.enable; };
    };

    config = {

        # Automatically run updates based on the GitHub repo instead of system.autoUpgrade
        # systemd timers recommended over cron by the NixOS Wiki
        # https://nixos.wiki/wiki/Systemd/Timers

        systemd.timers."js-autoupdate" = lib.mkIf config.js.autoUpdate.system {
            description = "Pulls the latest system updates from GitHub daily.";
            wantedBy = [ "timers.target" ]; # See https://unix.stackexchange.com/questions/427346/im-writing-a-systemd-timer-what-value-should-i-use-for-wantedby
            timerConfig = {
                OnCalendar = "12:00:00";
                Unit = "js-autoupdate.service";
                Persistent = true;
            };
        };

        systemd.services."js-autoupdate" = lib.mkIf config.js.autoUpdate.system {
            script = "../scripts/update.sh"; # TODO pass config location to the script
            serviceConfig = {
                Type = "oneshot";
                User = "root";
            };
        };

        # We need git and libnotify for this to work
        # yes it's declared elsewhere, no i don't care
        environment.systemPackages = with pkgs; lib.mkIf config.js.autoUpdate.system [
            git
            libnotify
        ];

        # Enable automatic firmware updates https://nixos.wiki/wiki/Fwupd
        services.fwupd.enable = lib.mkIf config.js.autoUpdate.firmware true;

        # Clean up old generations weekly
        # https://github.com/kjhoerr/dotfiles/blob/trunk/.config/nixos/os/upgrade.nix
        nix.gc = lib.mkIf config.js.autoUpdate.gc {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };

    };

}
