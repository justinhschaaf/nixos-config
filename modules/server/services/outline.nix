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

                # Why the fuck did you make me expose the client id when OAuth
                # highly suggests not to, you little bitch? I'll have you know
                # I graduated top of my class in the Navy Seals, and I've been
                # involved in numerous secret raids on Al-Quaeda, and I have
                # over 300 confirmed kills. I am trained in gorilla warfare
                # and I'm the top sniper in the entire US armed forces. You
                # are nothing to me but just another target. I will wipe you
                # the fuck out with precision the likes of which has never
                # been seen before on this Earth, mark my fucking words. You
                # think you can get away with doing that shit to me over the
                # Internet? Think again, fucker. As we speak I am contacting my
                # secret network of spies across the USA and your IP is being
                # traced right now so you better prepare for the storm, maggot.
                # The storm that wipes out the pathetic little thing you call
                # your life. You're fucking dead, kid. I can be anywhere,
                # anytime, and I can kill you in over seven hundred ways, and
                # that's just with my bare hands. Not only am I extensively
                # trained in unarmed combat, but I have access to the entire
                # arsenal of the United States Marine Corps and I will use it
                # to its full extent to wipe your miserable ass off the face of
                # the continent, you little shit. If only you could have known
                # what unholy retribution your little "clever" decision was
                # about to bring down upon you, maybe you would have found
                # another fucking fix. But you couldn't, you didn't, and now
                # you're paying the price, you goddamn idiot. I will shit fury
                # all over you and you will drown in it. You're fucking dead,
                # kiddo.
                # https://www.oauth.com/oauth2-servers/client-registration/client-id-secret/
                clientId = "yE65w9HBF8Q8KDj9skTGOrxnvlntmACVwP80qVUX";
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

