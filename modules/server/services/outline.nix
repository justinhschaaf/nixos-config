{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.outline.enable = lib.mkEnableOption "Outline, the fastest knowledge base for growing teams";
        js.server.outline.hostName = lib.mkOption { type = lib.types.str; };
        js.server.outline.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.outline.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.outline.openFirewall [ config.services.outline.port ];

        sops.secrets."outline/outline-env".sopsFile = ../../secrets/server.yaml;
        
        services.outline = lib.attrsets.recursiveUpdate {
        
            enable = true;
            port = 4000; # default is 3000, can't be having that
            publicUrl = "https://${config.js.server.outline.hostName}";
            forceHttps = true;
            storage.storageType = "local";

            smtp = {
                host = "smtp-relay.brevo.com";
                port = 587;
                fromEmail = "sysadmin@justinschaaf.com";
                replyEmail = "sysadmin@justinschaaf.com";
            };
            
        } (lib.attrsets.optionalAttrs config.js.server.cluster.guest.enable {
            databaseUrl = "postgres://outline:outline@${config.js.server.cluster.host.ip}:5432/outline_db";
            redisUrl = "redis://${config.js.server.cluster.host.ip}:6320";
        });

        # SMTP username and password are here
        systemd.services.outline.serviceConfig.EnvironmentFile = "/run/secrets/outline/outline-env";

        services.caddy.virtualHosts."${config.js.server.outline.hostName}".extraConfig = 
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.outline.port}
            '';
    
    };

}

