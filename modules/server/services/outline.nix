{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.outline.enable = lib.mkEnableOption "Outline, the fastest knowledge base for growing teams";
        js.server.outline.hostName = lib.mkOption { type = lib.types.str; };
        js.server.outline.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.outline.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.outline.openFirewall [ config.services.outline.port ];

        sops.secrets = let cfg = {
            sopsFile = ../../../secrets/server.yaml;
            owner = config.users.users.outline.name;
        }; in {
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
                username = "742e96001@smtp-brevo.com";
                passwordFile = "/run/secrets/outline/smtp-password";
                fromEmail = "sysadmin@justinschaaf.com";
                replyEmail = "sysadmin@justinschaaf.com";
            };

            oidcAuthentication = {
                clientSecretFile = "/run/secrets/outline/oidc-client-secret";
                authUrl = "https://${config.js.server.authentik.hostName}/application/o/authorize/";
                tokenUrl = "https://${config.js.server.authentik.hostName}/application/o/token/";
                userinfoUrl = "https://${config.js.server.authentik.hostName}/application/o/userinfo/";
                usernameClaim = "preferred_username";
                displayName = "authentik";
                scopes = [ "openid" "profile" "email" ];
                clientId = "";
            };

        };
        systemd.services.outline = {
            script =
              let
                localPostgresqlUrl = "postgres://localhost/outline?host=/run/postgresql";
                cfg = config.services.outline;
              in lib.mkForce ''
                  export SECRET_KEY="$(head -n1 ${lib.escapeShellArg cfg.secretKeyFile})"
                  export UTILS_SECRET="$(head -n1 ${lib.escapeShellArg cfg.utilsSecretFile})"
                  ${lib.optionalString (cfg.storage.storageType == "s3") ''
                    export AWS_SECRET_ACCESS_KEY="$(head -n1 ${lib.escapeShellArg cfg.storage.secretKeyFile})"
                  ''}
                  ${lib.optionalString (cfg.slackAuthentication != null) ''
                    export SLACK_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.slackAuthentication.secretFile})"
                  ''}
                  ${lib.optionalString (cfg.googleAuthentication != null) ''
                    export GOOGLE_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.googleAuthentication.clientSecretFile})"
                  ''}
                  ${lib.optionalString (cfg.azureAuthentication != null) ''
                    export AZURE_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.azureAuthentication.clientSecretFile})"
                  ''}
                  ${lib.optionalString (cfg.oidcAuthentication != null) ''
                    export OIDC_CLIENT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.oidcAuthentication.clientSecretFile})"

                    export OIDC_CLIENT_ID="$(cat ${config.sops.secrets."outline/oidc-client-secret".path})"  # TADA

                  ''}
                  ${lib.optionalString (cfg.sslKeyFile != null) ''
                    export SSL_KEY="$(head -n1 ${lib.escapeShellArg cfg.sslKeyFile})"
                  ''}
                  ${lib.optionalString (cfg.sslCertFile != null) ''
                    export SSL_CERT="$(head -n1 ${lib.escapeShellArg cfg.sslCertFile})"
                  ''}
                  ${lib.optionalString (cfg.slackIntegration != null) ''
                    export SLACK_VERIFICATION_TOKEN="$(head -n1 ${lib.escapeShellArg cfg.slackIntegration.verificationTokenFile})"
                  ''}
                  ${lib.optionalString (cfg.smtp != null) ''
                    export SMTP_PASSWORD="$(head -n1 ${lib.escapeShellArg cfg.smtp.passwordFile})"
                  ''}
            
                  ${
                    if (cfg.databaseUrl == "local") then
                      ''
                        export DATABASE_URL=${lib.escapeShellArg localPostgresqlUrl}
                        export PGSSLMODE=disable
                      ''
                    else
                      ''
                        export DATABASE_URL=${lib.escapeShellArg cfg.databaseUrl}
                      ''
                  }
            
                  ${cfg.package}/bin/outline-server
                '';
        };

        # SMTP username and password are here
        systemd.services.outline.serviceConfig.EnvironmentFile = "/run/secrets/outline/outline-env";

        services.caddy.virtualHosts."${config.js.server.outline.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.outline.port}
            '';

    };

}

