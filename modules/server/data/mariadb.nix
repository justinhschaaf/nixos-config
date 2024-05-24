{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.mariadb.enable = lib.mkEnableOption "MariaDB, an enhanced, drop-in replacement for MySQL";
        js.server.mariadb.ensureApplications = lib.mkOption { default = []; };
        js.server.mariadb.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.mariadb.openFirewall [ config.services.mysql.settings.mysqld.port ];
    
        services.mysql = lib.mkIf config.js.server.mariadb.enable {

            enable = true;

            ensureDatabases = config.js.server.mariadb.ensureApplications;
            ensureUsers = lib.lists.forEach config.js.server.mariadb.ensureApplications (x: {
                name = x;
                ensurePermissions = {
                    "${x}.*" = "ALL PRIVILEGES";
                };
            });

            settings.mysqld.port = 3306;
        
        };
    
    };

}

