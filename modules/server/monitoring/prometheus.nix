{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.prometheus = {
            enable = lib.mkEnableOption "the Prometheus monitoring system and time series database";
            openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
            exporters.node.enable = lib.mkEnableOption "the Prometheus node exporter";
            exporters.node.openFirewall = lib.mkOption { default = config.js.server.prometheus.openFirewall; };
            exporters.comin.enable = lib.mkEnableOption "the Prometheus exporter for Comin automatic updates";
            exporters.comin.openFirewall = lib.mkOption { default = config.js.server.prometheus.openFirewall; };
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

        services.comin.exporter = lib.mkIf config.js.server.prometheus.exporters.comin.enable {
            listen_address = "0.0.0.0";
            openFirewall = config.js.server.prometheus.exporters.comin.openFirewall;
        };

        # Send collected data from the exporter to Prometheus
        services.prometheus.scrapeConfigs = lib.attrsets.mapAttrsToList (name: value:
            if lib.typeOf value == "set"
            then value
            else {
                job_name = name;
                static_configs = [{
                    targets = if lib.typeOf value == "list"
                        then value
                        else [ "${toString value}" ];
                }];
            }) config.js.server.prometheus.scrapeFrom;

    };

}

