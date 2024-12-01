{ inputs, lib, config, pkgs, ... }: {

    imports = [
        inputs.waffleslol.nixosModules.default
    ];

    options = {
        js.server.waffles.lol.enable = lib.mkEnableOption "waffles.lol, the homelab homepage";
        js.server.waffles.lol.hostName = lib.mkOption { type = lib.types.str; };
        js.server.waffles.lol.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.waffles.lol.enable {

        # Open firewall
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.waffles.lol.openFirewall [ config.services.waffles.lol.port ];

        services.waffles.lol = {
            enable = true;
            hostName = config.js.server.waffles.lol.hostName;
            port = 3050; # for shits and giggles, let's see if this fixes it
        };

        services.caddy.virtualHosts."${config.js.server.waffles.lol.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.waffles.lol.port}
            '';

    };

}
