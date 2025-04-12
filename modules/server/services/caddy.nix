{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.caddy.enable = lib.mkEnableOption "Caddy, the ultimate server";
        js.server.caddy.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.caddy.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.caddy.openFirewall [ 80 443 ];

        # secrets
        sops.secrets."caddy/caddy-env".sopsFile = ../../../secrets/server.yaml;
        systemd.services.caddy.serviceConfig.EnvironmentFile = "/run/secrets/caddy/caddy-env";

        # NOTES FOR CLOUDFLARE
        # https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#defaults
        # https://caddy.community/t/caddy-cloudflare-err-too-many-redirects/3518
        services.caddy.enable = true;
        services.caddy.package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/cloudflare@v0.1.0" ];
            hash = "sha256-KnXqw7asSfAvKNSIRap9HfSvnijG07NYI3Yfknblcl4=";
        };

        # Add Cloudflare for DNS challenges
        # https://caddy.community/t/how-to-use-dns-provider-modules-in-caddy-2/8148
        # https://samjmck.com/en/blog/using-caddy-with-cloudflare/#2-using-a-lets-encrypt-certificate
        # https://letsdebug.net
        # Then add trusted_proxies static IPs
        # https://caddyserver.com/docs/caddyfile/options
        # https://www.cloudflare.com/ips/
        # if i'm gonna be honest these docs are confusing af
        services.caddy.globalConfig = ''
            acme_dns cloudflare {env.ACME_DNS_CLOUDFLARE_TOKEN}
            servers {
                trusted_proxies static private_ranges 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32
                trusted_proxies_strict
                metrics
            }
        '';

    };

}
