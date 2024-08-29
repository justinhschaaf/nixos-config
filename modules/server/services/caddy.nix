{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.caddy.enable = lib.mkEnableOption "Caddy, the ultimate server";
        js.server.caddy.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.caddy.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.caddy.openFirewall [ 80 443 ];

        # Note for Cloudflare setup https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#defaults
        services.caddy.enable = true;
    
    };

}

