{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.moonraker.enable = lib.mkEnableOption "Moonraker, the web server for Klipper";
        js.server.moonraker.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.moonraker.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.moonraker.openFirewall [ config.services.moonraker.port ];

        sops.secrets."moonraker/secrets" = {
            format = "json";
            sopsFile = ../../../secrets/ender-moonraker.json;
            owner = config.services.moonraker.user;
            path = "${config.services.moonraker.stateDir}/moonraker.secrets";
            key = ""; # this means the whole file is the secret, which is what we need since moonraker wants json
        };

        services.moonraker.enable = true;
        services.moonraker.allowSystemControl = true;
        services.moonraker.settings = {

            announcements.subscriptions = [ "fluidd" ];

            authorization = {
                force_logins = true;
                default_source = "ldap";
                trusted_clients = [
                    "127.0.0.0/8"
                    "10.10.22.19"
                    "::1/128"
                ];
                cors_domains = [
                    "*.waffles.lol"
                    "*.lan"
                    "*.local"
                    "*://localhost"
                    "*://localhost:*"
                    "*://my.mainsail.xyz"
                    "*://app.fluidd.xyz"
                    "*://10.10.22.19"
                ];
            };

            ldap = {
                ldap_host = "10.10.22.20";
                ldap_port = 3389;
                ldap_secure = false;
                base_dn = "dc=ldap,dc=goauthentik,dc=io";
                bind_dn = "{secrets.moonraker_ldap.bind_dn}";
                bind_password = "{secrets.moonraker_ldap.bind_password}";
                user_filter = "(&(objectClass=user)(cn=USERNAME)(memberOf=cn=iam-fluidd,ou=groups,dc=ldap,dc=goauthentik,dc=io))";
            };

        };

    };

}
