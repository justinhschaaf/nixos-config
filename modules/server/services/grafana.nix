{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.grafana.enable = lib.mkEnableOption "Grafana, the gorgeous metric viz, dashboards & editors for Graphite, InfluxDB & OpenTSDB";
        js.server.grafana.hostName = lib.mkOption { type = lib.types.str; };
        js.server.grafana.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.grafana.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.grafana.openFirewall [ config.services.grafana.settings.server.http_port ];

        sops.secrets = let cfg = {
            sopsFile = ../../../secrets/server.yaml;
            owner = config.users.users.grafana.name; # Make sure Grafana can access its own secrets
        }; in {
            "grafana/secret-key" = cfg;
            "grafana/smtp-user" = cfg;
            "grafana/smtp-password" = cfg;
            "grafana/oauth-client-id" = cfg;
            "grafana/oauth-client-secret" = cfg;
        };

        # All options: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#paths
        services.grafana.enable = true;
        services.grafana.settings = {

            server = {
                protocol = "https";
                domain = config.js.server.grafana.hostName;
                enforce_domain = true;
                enable_gzip = true;
                http_port = 4500; # default is 3000, can't be having that
                root_url = "%(protocol)s://%(domain)s/"; # removed the port from this
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

            auth = {
                signout_redirect_url = "https://${config.js.server.authentik.hostName}/application/o/grafana/end-session/";
                disable_login_form = true;
            };

            # OAuth only
            "auth.basic".enabled = false;

            "auth.generic_oauth" = {

                name = "authentik";
                enabled = true;
                auto_login = true;
                client_id = "$__file{/run/secrets/grafana/oauth-client-id}";
                client_secret = "$__file{/run/secrets/grafana/oauth-client-secret}";
                scopes = "openid email profile";
                auth_url = "https://${config.js.server.authentik.hostName}/application/o/authorize/";
                token_url = "https://${config.js.server.authentik.hostName}/application/o/token/";
                api_url = "https://${config.js.server.authentik.hostName}/application/o/userinfo/";
                allow_assign_grafana_admin = true; # lets us assign the GrafanaAdmin role with Authentik

                # Role mapping - allows us to map Authentik user groups to Grafana roles
                role_attribute_path = "contains(groups, 'iam-grafana-serveradmin') && 'GrafanaAdmin' || contains(groups, 'iam-grafana-admin') && 'Admin' || contains(groups, 'iam-grafana-editor') && 'Editor' || contains(groups, 'iam-grafana-viewer') && 'Viewer'";

            };

        };

        services.caddy.virtualHosts."${config.js.server.grafana.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.grafana.settings.server.http_port}
            '';

    };

}

