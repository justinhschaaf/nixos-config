{ inputs, lib, config, pkgs, ... }: {

    options.js.server.seafile = {
        enable = lib.mkEnableOption "Seafile, the Next-generation Open Source Cloud Storage";
        hostName = lib.mkOption { type = lib.types.str; };
        openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.seafile.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.seafile.openFirewall [ 8000 8082 ];

        services.seafile = {

            # haha good catch GitGuardian, i really give a shit about a password
            # that will be changed by the time this is ever accessible to a
            # public network
            initialAdminPassword = "Spaghett!0s"; # this will be changed when deployed so don't try it
            adminEmail = "sysadmin@justinschaaf.com";
            enable = true;

            ccnetSettings.General.SERVICE_URL = "https://${config.js.server.seafile.hostName}";

            # TODO https://manual.seafile.com/latest/config/oauth/
            seafileSettings = {
                quota.default = 5; # in gb
                library_trash.espire_days = 60;
                fileserver.use_go_fileserver = true;
            };

        };

        # https://forum.seafile.com/t/notification-server-behind-caddy/19326
        # https://forum.seafile.com/t/caddy-reverse-proxy-for-seafile/19525
        services.caddy.virtualHosts."${config.js.server.seafile.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                handle_path /seafhttp* {
                    reverse_proxy 127.0.0.1:8082
                }
                handle_path /media* {
                    root * /var/lib/seafile/seahub
                    file_server
                }
                handle {
                    reverse_proxy 127.0.0.1:8000
                }
            '';

    };

}

