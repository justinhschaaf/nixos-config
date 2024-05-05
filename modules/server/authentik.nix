{ inputs, lib, config, pkgs, ... }: {

    imports = [ 
        inputs.authentik-nix.nixosModules.default
    ];

    options = {
        js.server.authentik.enable = lib.mkEnableOption "Authentik, the authentication glue you need";
        js.server.authentik.hostName = lib.mkOption { type = lib.types.str };
    };

    config = lib.mkIf config.js.server.authentik.enable {

        sops.secrets."authentik/authentik-env" = {
            sopsFile = ../../secrets/server.yaml;
        };

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

        services.caddy = lib.mkIf config.js.server.caddy.enable {
            virtualHosts."${config.js.server.authentik.hostName}" = {
                # https://docs.goauthentik.io/docs/installation/reverse-proxy
                # Headers should already be set, see https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#defaults
                extraConfig = ''
                    handle {
                        reverse_proxy 127.0.0.1:9443
                    }
                '';
            };
        };
    
    };

}

