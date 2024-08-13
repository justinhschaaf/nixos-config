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

            ensureDatabases = lib.lists.forEach config.js.server.postgres.ensureApplications (x: "${x}_db");
            ensureUsers = lib.lists.forEach config.js.server.postgres.ensureApplications (x: {
                name = x;
                ensureDBOwnership = true;
            });
            
        };
    
    };

}

