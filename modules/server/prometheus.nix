{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.prometheus.enable = lib.mkEnableOption "the Prometheus monitoring system and time series database";
        js.server.prometheus.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.prometheus.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.prometheus.openFirewall [ config.services.prometheus.port ];

        # Enable Prometheus
        services.prometheus.enable = true;

        # Collect default system and systemd data
        services.prometheus.exporters.node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
            openFirewall = config.js.server.prometheus.openFirewall;
        };

        # Send collected data from the exporter to Prometheus
        services.prometheus.scrapeConfigs = [{
            job_name = config.networking.hostName;
            static_configs = [{
                targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }];
        }];
    
    };

}

