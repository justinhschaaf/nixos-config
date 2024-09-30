{ inputs, lib, config, pkgs, system, ... }: {

    options = {
        js.update = {
            enable = lib.mkEnableOption "automatic updates";
            sendNotif = lib.mkEnableOption "libnotify notifications for automatic update progress";
            firmware.enable = lib.mkOption { default = config.js.update.enable; };
            gc.enable = lib.mkOption { default = config.js.update.enable; };
            system.enable = lib.mkOption { default = config.js.update.enable; };
            system.rebuildCmd = lib.mkOption { 
                type = lib.types.enum [ "boot" "switch" "test" ];
                default = "boot";
                description = "Specify which command to use when rebuilding the system config.";
            };
        };
    };

    config = {

        # Automatically run updates based on the GitHub repo instead of system.autoUpgrade
        # systemd timers recommended over cron by the NixOS Wiki
        # https://wiki.nixos.org/wiki/Systemd/Timers

        environment.systemPackages = lib.mkIf (config.js.update.firmware.enable || config.js.update.system.enable) [
            inputs.self.outputs.packages.${system}.jsupdate
        ];

        systemd = lib.mkIf (config.js.update.firmware.enable || config.js.update.system.enable) {

            timers."jsupdate" = {
                description = "Pulls the latest system updates from GitHub shortly after boot and daily afterwards.";
                timerConfig = {
                    OnBootSec = "15m"; # Run 15 minutes after booting
                    OnUnitActiveSec = "1d"; # ...and daily afterwards
                    Unit = "jsupdate.service";
                };
            };

            services."jsupdate" = let
                firmwareUpdateArgs = if config.js.update.firmware.enable then " -f" else "";
                systemUpdateArgs = if config.js.update.system.enable
                    then " -c -r ${config.js.update.system.rebuildCmd}"
                    else "";
                notifyArgs = if config.js.update.sendNotif then " -n" else "";
            in {
                script = "${inputs.self.outputs.packages.${system}.jsupdate}/bin/jsupdate"
                    + firmwareUpdateArgs
                    + systemUpdateArgs
                    + notifyArgs;
                serviceConfig = {
                    Type = "oneshot";
                    User = "root";
                };
            };
        
        };

        # Clean up old generations weekly
        # https://github.com/kjhoerr/dotfiles/blob/trunk/.config/nixos/os/upgrade.nix
        # https://github.com/viperML/nh?tab=readme-ov-file#nixos-module
        programs.nh.clean = {
            enable = config.js.update.gc.enable;
            dates = "weekly";
            extraArgs = "--keep-since 30d";
        };

    };

}

