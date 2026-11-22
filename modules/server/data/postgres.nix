{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.postgres.enable = lib.mkEnableOption "PostgreSQL, a powerful, open source object-relational database system";
        js.server.postgres.ensureApplications = lib.mkOption { default = []; };
        js.server.postgres.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.postgres.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.postgres.openFirewall [ config.services.postgresql.settings.port ];

        services.postgresql = {

            enable = true;

            # package must be set to a fixed version as manual upgrades are required, see steps below
            package = pkgs.postgresql_18;

            ensureDatabases = lib.lists.forEach config.js.server.postgres.ensureApplications (x: "${x}_db");
            ensureUsers = lib.lists.forEach config.js.server.postgres.ensureApplications (x: {
                name = x;
                ensureDBOwnership = true;
            });

        };

        # Install automatic pgsql upgrade script
        # Taken from https://nixos.org/manual/nixos/stable/#module-postgresql
        # Further advice at https://wiki.nixos.org/wiki/PostgreSQL#Major_upgrades
        # Upgrade Process:
        # - Login as root (sudo su -).
        # - Run upgrade-pg-cluster
        # - Change the package version above and rebuild
        # - Run vacuumdb --all --analyze-in-stages
        environment.systemPackages = [(
            let
                # Specify the postgresql package to upgrade to.
                newPostgres = pkgs.postgresql_18;
                cfg = config.services.postgresql;
            in pkgs.writeScriptBin "upgrade-pg-cluster" ''
                set -eux
                # it's perhaps advisable to stop all services that depend on postgresql
                systemctl stop postgresql

                export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
                export NEWBIN="${newPostgres}/bin"

                export OLDDATA="${cfg.dataDir}"
                export OLDBIN="${cfg.finalPackage}/bin"

                install -d -m 0700 -o postgres -g postgres "$NEWDATA"
                cd "$NEWDATA"
                sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}

                sudo -u postgres "$NEWBIN/pg_upgrade" \
                    --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
                    --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
                    "$@"
            ''
        )];

    };

}

