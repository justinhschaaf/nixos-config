{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.grafana.enable = lib.mkEnableOption "Grafana, the gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB";
        js.server.grafana.hostName = lib.mkOption { type = lib.types.str; };
        js.server.grafana.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.grafana.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.grafana.openFirewall [ config.services.grafana.settings.server.http_port ];

        sops.secrets = let
            cfg.sopsFile = ../../../secrets/server.yaml;
        in {
            "grafana/secret-key" = cfg;
            "grafana/smtp-user" = cfg;
            "grafana/smtp-password" = cfg;
        };

        # All options: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#paths
        services.grafana.enable = true;
        services.grafana.settings = {
            
            server = {
                protocol = "https";
                domain = config.js.server.grafana.hostName;
                #enforce_domain = true; # TODO enable when in prod
                enable_gzip = true;
                http_port = 4500; # default is 3000, can't be having that
            };

            analytics = {
                reporting_enabled = false;
                check_for_updates = false;
                check_for_plugin_updates = false;
            };

            security = {
                disable_initial_admin_creation = true;
                disable_gravatar = true;
                secret_key = "$__file{/run/secrets/grafana/secret-key}";
                cookie_secure = true;
                cookie_samesite = "strict";
            };

            smtp = {
                enabled = true;
                host = "smtp-relay.brevo.com:587";
                user = "$__file{/run/secrets/grafana/smtp-user}";
                password = "$__file{/run/secrets/grafana/smtp-password}";
                from_address = "grafana.3lhnr@waffles.lol";
                startTLS_policy = "MandatoryStartTLS";
            };
            
        };

        services.caddy.virtualHosts."${config.js.server.grafana.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.grafana.settings.server.http_port}
            '';
    
    };

}

