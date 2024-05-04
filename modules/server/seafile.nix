{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.seafile.enable = lib.mkEnableOption "Seafile, the Next-generation Open Source Cloud Storage";
    };

    config = lib.mkIf config.js.server.seafile.enable {

        services.seafile = {
            enable = true;
            adminEmail = "sysadmin@justinschaaf.com";
            # haha good catch GitGuardian, i really give a shit about a password
            # that will be changed by the time this is ever accessible to a 
            # public network
            initialAdminPassword = "Spaghett!0s"; # this will be changed when deployed so don't try it
            seafileSettings = {
                quota.default = 5; # in gb
                library_trash.espire_days = 60;
                fileserver.use_go_fileserver = true;
            };
        };

    };

}

