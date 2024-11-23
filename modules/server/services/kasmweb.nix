{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.kasmweb.enable = lib.mkEnableOption "Kasm Workspaces, the workspace streaming platform";
        js.server.kasmweb.hostName = lib.mkOption { type = lib.types.str; };
        js.server.kasmweb.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.grafana.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.kasmweb.openFirewall [ config.services.kasmweb.listenPort ];

        # The NixOS module options are documented like shit, so im gonna guess i don't have to worry about the rest
        # This is being reverse proxied anyways we'll be fiiiiiiiiiiiiiiine
        services.kasmweb.enable = true;
        services.kasmweb.listenPort = 8483; # something that isn't standard

        systemd.services."init-kasmweb".serviceConfig.TimeoutStartSec = lib.mkForce 1800;

        services.caddy.virtualHosts."${config.js.server.kasmweb.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.kasmweb.listenPort}
            '';

    };

}

