{ inputs, lib, config, pkgs, ... }: {

    options.js.server.youtrack = {
        enable = lib.mkEnableOption "YouTrack, powerful project management for all your teams";
        hostName = lib.mkOption { type = lib.types.str; };
        openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.youtrack.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.youtrack.openFirewall [ config.services.youtrack.environmentalParameters.listen-port ];

        services.youtrack = {
            enable = true;
            environmentalParameters = {
                base-url = "https://${config.js.server.youtrack.hostName}";
                secure-mode = "disable";
                listen-port = 8380;
            };
        };

        services.caddy.virtualHosts."${config.js.server.youtrack.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy ${config.services.youtrack.address}:${toString config.services.youtrack.environmentalParameters.listen-port}
            '';

    };

}
