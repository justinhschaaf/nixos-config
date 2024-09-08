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

        # Add trusted_proxies static IPs
        # https://caddyserver.com/docs/caddyfile/options
        # https://www.cloudflare.com/ips/
        # if i'm gonna be honest these docs are confusing af
        services.caddy.extraConfig = ''
            {
                servers {
                    trusted_proxies static private_ranges 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32
                    trusted_proxies_strict
                    metrics
                }
            }
        '';
    
    };

}
