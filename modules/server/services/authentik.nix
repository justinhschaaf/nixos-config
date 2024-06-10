{ inputs, lib, config, pkgs, ... }: {

    imports = [ 
        inputs.authentik-nix.nixosModules.default
    ];

    options = {
        js.server.authentik.enable = lib.mkEnableOption "Authentik, the authentication glue you need";
        js.server.authentik.hostName = lib.mkOption { type = lib.types.str; };
        js.server.authentik.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
        js.server.authentik.openFirewallMetrics = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.authentik.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.authentik.openFirewall [ 9443 ]
            ++ lib.optionals config.js.server.authentik.openFirewallMetrics [ 9300 ];

        sops.secrets."authentik/authentik-env".sopsFile = ../../secrets/server.yaml;

        services.authentik = lib.attrsets.recursiveUpdate {
            enable = true;
            environmentFile = "/run/secrets/authentik/authentik-env";
            settings = {
            
                email = {
                    host = "smtp-relay.brevo.com";
                    port = 587;
                    use_tls = true;
                    use_ssl = false;
                    from = "System Administrator <sysadmin@justinschaaf.com>";
                };

                # Air-gap the environment, Gravatars are cool though...
                disable_startup_analytics = true;
                disable_update_check = true;
                error_reporting.enabled = false;
                
            };
        } (lib.attrsets.optionalAttrs config.js.server.cluster.node.enable {
        
            createDatabase = false;

            settings.postgresql = {
                host = config.js.server.cluster.host.ip;
                user = "authentik";
                name = "authentik_db";
            };

            settings.redis = {
                host = config.js.server.cluster.host.ip;
                port = 6310;
            };
        
        });

        # https://docs.goauthentik.io/docs/installation/reverse-proxy
        # Headers should already be set, see https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#defaults
        services.caddy.virtualHosts."${config.js.server.authentik.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:9443
            '';
    
    };

}

