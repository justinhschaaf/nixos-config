{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.caddy.enable = lib.mkEnableOption "Caddy, the ultimate server";
        js.server.caddy.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.caddy.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.caddy.openFirewall [ 80 443 ];

        # NOTES FOR CLOUDFLARE
        # https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#defaults
        # https://caddy.community/t/caddy-cloudflare-err-too-many-redirects/3518
        services.caddy.enable = true;
    
    };

}

