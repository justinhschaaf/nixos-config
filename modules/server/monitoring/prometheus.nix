{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.prometheus = {
            enable = lib.mkEnableOption "the Prometheus monitoring system and time series database";
            openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
            exporters.node.enable = lib.mkEnableOption "the Prometheus node exporter";
            exporters.node.openFirewall = lib.mkOption { default = config.js.server.prometheus.openFirewall };
            scrapeFrom = lib.mkOption { default = {}; }; # "${config.networking.hostName}" = "route on the host:exporter port"
        };
    };

    config = {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.prometheus.openFirewall [ config.services.prometheus.port ];

        # Enable Prometheus
        services.prometheus.enable = config.js.server.prometheus.enable;

        # Collect default system and systemd data
        services.prometheus.exporters.node = lib.mkIf config.js.server.prometheus.exporters.node.enable {
            enable = true;
            enabledCollectors = [ "systemd" ];
            openFirewall = config.js.server.prometheus.exporters.node.openFirewall;
        };

        # Send collected data from the exporter to Prometheus
        services.prometheus.scrapeConfigs = lib.attrsets.mapAttrsToList (name: value: 
            if typeOf value == "set"
            then value
            else {
                job_name = name;
                static_configs = [{
                    targets = if typeOf value == "list" 
                        then value
                        else [ "${toString value}" ];
                }];
            }) js.server.prometheus.scrapeFrom;
    
    };

}

