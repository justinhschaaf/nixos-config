{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.outline.enable = lib.mkEnableOption "Outline, the fastest knowledge base for growing teams";
        js.server.outline.hostName = lib.mkOption { type = lib.types.str; };
        js.server.outline.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.outline.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.outline.openFirewall [ config.services.outline.port ];

        sops.secrets = let
            cfg.sopsFile = ../../../secrets/server.yaml;
        in {
            "outline/outline-env" = cfg;
            "outline/smtp-password" = cfg;
            "outline/oidc-client-secret" = cfg;
        };

        services.outline = {

            enable = true;
            port = 4000; # default is 3000, can't be having that
            publicUrl = "https://${config.js.server.outline.hostName}";
            forceHttps = false; # caddy takes care of this for us, https on local network fucks shit up
            storage.storageType = "local";

            smtp = {
                host = "smtp-relay.brevo.com";
                port = 587;
                username = "$REAL_SMTP_USERNAME";
                passwordFile = "/run/secrets/outline/smtp-password";
                fromEmail = "sysadmin@justinschaaf.com";
                replyEmail = "sysadmin@justinschaaf.com";
            };

            oidcAuthentication = {
                clientId = "$REAL_OIDC_CLIENT_ID";
                clientSecretFile = "/run/secrets/outline/oidc-client-secret";
                authUrl = "https://${config.js.server.authentik.hostName}/application/o/authorize/";
                tokenUrl = "https://${config.js.server.authentik.hostName}/application/o/token/";
                userinfoUrl = "https://${config.js.server.authentik.hostName}/application/o/userinfo/";
                usernameClaim = "preferred_username";
                displayName = "authentik";
                scopes = [ "openid" "profile" "email" ];
            };

        };

        # SMTP username and password are here
        systemd.services.outline.serviceConfig.EnvironmentFile = "/run/secrets/outline/outline-env";

        services.caddy.virtualHosts."${config.js.server.outline.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.outline.port}
            '';

    };

}

