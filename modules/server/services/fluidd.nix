{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.fluidd.enable = lib.mkEnableOption "Fluidd, a Klipper web interface for managing your 3d printer";
        js.server.fluidd.hostName = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
        };
        js.server.fluidd.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.fluidd.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.fluidd.openFirewall [ 80 443 ];

        services.fluidd.enable = true;
        services.fluidd.hostName = config.js.server.fluidd.hostName;
        services.fluidd.nginx.addSSL = true; # doing add for now since idk if nginx makes its own cert

        # no need to setup caddy yet

    };

}
