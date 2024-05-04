{ inputs, lib, config, pkgs, ... }: {

    imports = [ 
        inputs.authentik-nix.nixosModules.default
    ];

    options = {
        js.server.authentik.enable = lib.mkEnableOption "Authentik, the authentication glue you need";
    };

    config = lib.mkIf config.js.server.authentik.enable {

        sops.secrets."authentik/authentik-env" = {
            sopsFile = ../../secrets/server.yaml;
        };

        services.authentik = {
            enable = true;
            environmentFile = "/run/secrets/authentik/authentik-env";
            settings.email = {
                host = "smtp-relay.brevo.com";
                port = 465;
                use_tls = true;
                use_ssl = false;
                from = "System Administrator <sysadmin@justinschaaf.com>";
            };
        };

    };

}

