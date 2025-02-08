{ inputs, lib, config, pkgs, system, ... }: {

    options.js.backup = {
        enable = lib.mkEnableOption "automatic backups";
        src = lib.mkOption {
            type = lib.types.path;
            description = "The source directory to backup.";
        };
        dest = lib.mkOption {
            type = lib.types.path;
            description = "The directory where all backups should be kept.";
        };
        mount = {
            enable = lib.mkEnableOption "backups to a mounted drive";
            device = lib.mkOption {
                type = lib.types.str;
                description = "The drive which should be mounted.";
            };
            dir = lib.mkOption {
                type = lib.types.path;
                description = "Where the drive should be mounted to. Will be created if it doesn't exist.";
            };
        };
        excludes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "A list of files and directories which should be excluded from the backup.";
        };
        keep = lib.mkOption {
            type = lib.types.ints.between 0 512;
            description = "The number of backups to keep. Set to 0 to keep all.";
            default = 28;
        };
    };

    config = lib.mkIf config.js.backup.enable {

        environment.systemPackages = [ inputs.self.outputs.packages.${system}.jsbackup ];

        systemd = {

            timers."jsbackup" = {
                description = "Performs an incremental backup every day.";
                wantedBy = [ "multi-user.target" ];
                timerConfig = {
                    # https://silentlad.com/systemd-timers-oncalendar-(cron)-format-explained
                    OnCalendar = "*-*-* 12:00:00"; # Daily at 12pm
                    Persistent = "true";
                    Unit = "jsbackup.service";
                };
            };

            services."jsbackup" = let
                args = " \"${toString config.js.backup.src}\" \"${toString config.js.backup.dest}\"";
                mountArgs = if config.js.backup.mount.enable
                    then " -d ${config.js.backup.mount.device} -p \"${toString config.js.backup.mount.dir}\""
                    else "";
                keepArgs = " -k ${toString config.js.backup.keep}";
                excludes = pkgs.writeText "jsbackup-excludes" (lib.strings.concatLines config.js.backup.excludes);
                excludesArgs = " -e \"${excludes}\"";
            in {
                script = "${inputs.self.outputs.packages.${system}.jsbackup}/bin/jsbackup"
                    + mountArgs
                    + keepArgs
                    + excludesArgs
                    + args;
                serviceConfig = {
                    Type = "exec"; # https://man.archlinux.org/man/systemd.service.5#OPTIONS
                    User = "root";
                };
            };

        };

    };

}
