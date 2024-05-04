{ inputs, lib, config, pkgs, ... }: {

    imports = [ 
        inputs.authentik-nix.nixosModules.default
    ];

    options = {
        js.server.enable = lib.mkEnableOption "server defaults";
    };

    config = lib.mkIf config.js.server.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = [ 80 443 ];

        # Enable SSH
        services.openssh = {
            enable = true;
            ports = [ 2720 ];
            openFirewall = true;
            settings.UseDns = true;
            settings.PermitRootLogin = "no";
        };

        # Tarpits to fuck with attackers
        services.endlessh-go = {
            enable = true;
            port = 22;
            openFirewall = true;
        };

        services.caddy = {
            enable = true;
            virtualHosts."localhost".extraConfig = ''
            respond "Hello, world!"
            '';
        };

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

        services.seafile = {
            enable = true;
            adminEmail = "sysadmin@justinschaaf.com";
            initialAdminPassword = "Spaghett!0s"; # this will be changed when deployed so don't try it
            seafileSettings = {
                quota.default = 5; # in gb
                library_trash.espire_days = 60;
                fileserver.use_go_fileserver = true;
            };
        };
    
    };

}

