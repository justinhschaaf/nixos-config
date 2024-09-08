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
        # Don't open 9000, we want to use HTTPS for internal access
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.authentik.openFirewall [ 9443 ]
            ++ lib.optionals config.js.server.authentik.openFirewallMetrics [ 9300 ];

        sops.secrets."authentik/authentik-env".sopsFile = ../../../secrets/server.yaml;

        services.authentik = {
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
        };

        # https://docs.goauthentik.io/docs/installation/reverse-proxy
        # Headers should already be set, see https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#defaults
        # Must use HTTP here or else we run into a bad gateway error
        services.caddy.virtualHosts."${config.js.server.authentik.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:9000
            '';

    };

}

