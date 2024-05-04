{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.seafile.enable = lib.mkEnableOption "Seafile, the Next-generation Open Source Cloud Storage";
        js.server.seafile.hostName = lib.mkOption { type = lib.types.str };
    };

    config = lib.mkIf config.js.server.seafile.enable {

        services.seafile = {
            enable = true;
            adminEmail = "sysadmin@justinschaaf.com";
            # haha good catch GitGuardian, i really give a shit about a password
            # that will be changed by the time this is ever accessible to a 
            # public network
            initialAdminPassword = "Spaghett!0s"; # this will be changed when deployed so don't try it
            ccnetSettings.General.SERVICE_URL = "https://${config.js.server.seafile.hostName}"
            seafileSettings = {
                quota.default = 5; # in gb
                library_trash.espire_days = 60;
                fileserver.use_go_fileserver = true;
            };
        };

        services.caddy = lib.mkIf config.js.server.caddy.enable {
            virtualHosts."${config.js.server.seafile.hostName}" = {
                # https://forum.seafile.com/t/notification-server-behind-caddy/19326
                # https://forum.seafile.com/t/caddy-reverse-proxy-for-seafile/19525
                extraConfig = ''
                    handle_path /seafile/notification/* {
                        @websockets {
                            header Connection *Upgrade*
                            header Upgrade    websocket
                        }
                        reverse_proxy @websockets 127.0.0.1:8083
                    }
                    handle_path /seafhttp* {
                        reverse_proxy 127.0.0.1:8082
                    }
                    handle_path /seafdav* {
                        reverse_proxy 127.0.0.1:8080
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
        };
    
    };

}

