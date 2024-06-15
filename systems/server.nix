{ inputs, lib, config, pkgs, guests, ... }: {

    # Autoupdate.
    #js.autoUpdate.enable = true;
    #js.autoUpdate.system.rebuildCmd = "switch";

    js.sops.enable = true;
    js.server = {
    
        enable = true;
        openFirewall = false; # openFirewall != port forwarded, only accessible to internal network
        
        ssh.enable = true;
        ssh.openFirewall = true;

        mariadb.enable = true;
        mariadb.openFirewall = true;

        postgres.enable = true;
        postgres.openFirewall = true;
        postgres.ensureApplications = [
            "authentik"
            "grafana"
            "outline"
        ];

        redis.enable = true;
        redis.ensureApplications = [{
            name = "authentik";
            port = 6310;
        } {
            name = "seahub";
            port = 6315;
        } {
            name = "outline";
            port = 6320;
        } {
            name = "grafana";
            port = 6325;
        }];
        
        # This needs to be disabled since the redis servers will
        # be accessed from the VMs instead of the host machine.
        redis.defaultSettings.settings.protected-mode = false;

        prometheus.enable = true;
        prometheus.exporters.node.enable = true;
        prometheus.scrapeFrom = { # local exporters
            "node-${networking.hostName}" = "127.0.0.1:${services.prometheus.exporters.node.port}";
        } // listToAttrs (lib.lists.forEach [ # what exporters we need from each vm
            { name = "node"; port = 9100; }
            { name = "authentik"; port = 9300; }
        ] (service: lib.lists.forEach config.js.server.cluster.guests (guest : { # add the exporters
            name = "${service.name}-${guest.hostName}";
            value = "${guest.ip}:${toString service.port}";
        })));

        loki.enable = true;
        loki.agents.promtail.enable = true;
        
        caddy.enable = true;
        caddy.openFirewall = true; # we want this to be true even when disabling everything else

        cluster = {
        
            enable = true;
            host.enable = true;
            
            guests.all = guests;
            guests.config = guest: {
                flake = "path:/etc/nixos#${guest.hostName}";
                updateFlake = "path:/etc/nixos#${guest.hostName}";
                restartIfChanged = true;
            };
            
        };
        
    };

    # Special Snowflake Seafile MariaDB config

    services.mysql.ensureUsers = [{
        name = "seafile";
        ensurePermissions = {
            "ccnet_db.*" = "ALL PRIVILEGES";
            "seafile_db.*" = "ALL PRIVILEGES";
            "seahub_db.*" = "ALL PRIVILEGES";
        };
    }];

    services.mysql.ensureDatabases = [
        "ccnet_db"
        "seafile_db"
        "seahub_db"
    ];

    # Set system name
    networking.hostName = "tortelli";

}

