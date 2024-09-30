{ inputs, lib, config, pkgs, system, ... }: {

    options = {
        js.autoUpdate = {
            enable = lib.mkEnableOption "automatic updates";
            sendNotif = lib.mkEnableOption "libnotify notifications for automatic update progress";
            firmware.enable = lib.mkOption { default = config.js.autoUpdate.enable; };
            gc.enable = lib.mkOption { default = config.js.autoUpdate.enable; };
            system.enable = lib.mkOption { default = config.js.autoUpdate.enable; };
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

        environment.systemPackages = lib.mkIf (config.js.autoUpdate.firmware.enable || config.js.autoUpdate.system.enable) [
            inputs.self.outputs.packages.${system}.jsupdate
        ];

        systemd = lib.mkIf (config.js.autoUpdate.firmware.enable || config.js.autoUpdate.system.enable) {

            timers."jsupdate" = {
                description = "Pulls the latest system updates from GitHub shortly after boot and daily afterwards.";
                timerConfig = {
                    OnBootSec = "15m"; # Run 15 minutes after booting
                    OnUnitActiveSec = "1d"; # ...and daily afterwards
                    Unit = "jsupdate.service";
                };
            };

            services."jsupdate" = let
                firmwareUpdateArgs = if config.js.autoUpdate.firmware.enable then " -f" else "";
                systemUpdateArgs = if config.js.autoUpdate.system.enable 
                    then " -c -r ${config.js.autoUpdate.system.rebuildCmd}"
                    else "";
                notifyArgs = if config.js.autoUpdate.sendNotif then " -n" else "";
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
            enable = config.js.autoUpdate.gc.enable;
            dates = "weekly";
            extraArgs = "--keep-since 30d";
        };

    };

}
