{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.seafile.enable = lib.mkEnableOption "Seafile, the Next-generation Open Source Cloud Storage";
        js.server.seafile.hostName = lib.mkOption { type = lib.types.str; };
        js.server.seafile.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.seafile.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.seafile.openFirewall [ 8000 8080 8082 8083 ];

        services.seafile = lib.attrsets.recursiveUpdate {
        
            # haha good catch GitGuardian, i really give a shit about a password
            # that will be changed by the time this is ever accessible to a 
            # public network
            initialAdminPassword = "Spaghett!0s"; # this will be changed when deployed so don't try it
            adminEmail = "sysadmin@justinschaaf.com";
            enable = true;
            
            ccnetSettings.General.SERVICE_URL = "https://${config.js.server.seafile.hostName}";
            
            seafileSettings = {
                quota.default = 5; # in gb
                library_trash.espire_days = 60;
                fileserver.use_go_fileserver = true;
            };
            
        } (lib.attrsets.optionalAttrs config.js.server.cluster.guest.enable {

            ccnetSettings = {
                cluster.enabled = true;
                database = { # DB only for this, cache is pro only
                    type = "mysql";
                    host = config.js.server.cluster.host.ip;
                    port = 3306;
                    user = "seafile";
                    password = "seafile";
                    db_name = "ccnet_db";
                };
            };

            seafileSettings = {
                cluster.enabled = true;
                database = { # DB only for this, cache is pro only
                    type = "mysql";
                    host = config.js.server.cluster.host.ip;
                    port = 3306;
                    user = "seafile";
                    password = "seafile";
                    db_name = "seafile_db";
                };
            };

            seahubExtraConf = ''
                DATABASES = {
                    "default": {
                        "ENGINE": "django.db.backends.mysql",
                        "HOST": "${config.js.server.cluster.host.ip}",
                        "PORT": "3306",
                        "USER": "seafile",
                        "PASSWORD": "seafile",
                        "NAME": "seahub_db",
                    }
                }
                
                CACHES = {
                    "default": {
                        "BACKEND": "django.core.cache.backends.redis.RedisCache",
                        "LOCATION": "redis://${config.js.server.cluster.host.ip}:6315",
                    }
                }
            '';
        
        });

        # https://forum.seafile.com/t/notification-server-behind-caddy/19326
        # https://forum.seafile.com/t/caddy-reverse-proxy-for-seafile/19525
        services.caddy.virtualHosts."${config.js.server.seafile.hostName}".extraConfig = 
            lib.mkIf config.js.server.caddy.enable ''
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

}

