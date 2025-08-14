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

                # OAuth says you shouldn't expose the client secret but the
                # NixOS module demands it. Apparently, you can just make this a
                # blank screen to shut it up. OIDC_CLIENT_ID is now set in the
                # environment file below (which overrides the environment vars
                # NixOS sets), managed by SOPS.
                #
                # MASSIVE shoutout to k2on/Max Koon for making me see this
                # https://github.com/k2on
                #
                # https://www.oauth.com/oauth2-servers/client-registration/client-id-secret/
                # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Environment=
                # https://docs.getoutline.com/s/hosting/doc/oidc-8CPBm6uC0I
                clientId = "";
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

