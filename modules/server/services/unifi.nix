{ inputs, lib, config, pkgs, ... }: {

    options.js.server.unifi = {
        enable = lib.mkEnableOption "Unifi";
        hostName = lib.mkOption { type = lib.types.str; };
        openFirewallDiscovery = lib.mkOption { default = config.js.server.openFirewall; };
        openFirewallConsole = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.unifi.enable {

        # Open ports
        # As per Nixpkgs, services.unifi.openFirewall only opens the discovery port, not the console
        # https://search.nixos.org/options?channel=unstable&show=services.unifi.openFirewall&from=0&size=50&sort=relevance&type=packages&query=services.unifi
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.unifi.openFirewallConsole [ 8443 ];
        services.unifi.openFirewall = config.js.server.unifi.openFirewallDiscovery;

        services.unifi.enable = true;
        services.unifi.unifiPackage = pkgs.unifi;
        services.unifi.mongodbPackage = pkgs.mongodb;

        services.caddy.virtualHosts."${config.js.server.unifi.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:8443 {
                    transport http {
                    	tls_insecure_skip_verify
                    }
                }
            '';

    };

}
