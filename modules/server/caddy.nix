{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.caddy.enable = lib.mkEnableOption "Caddy, the ultimate server";
    };

    config = lib.mkIf config.js.server.caddy.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = [ 80 443 ];

        # Note for Cloudflare setup https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#defaults
        # TODO LetsEncrypt setup
        # TODO homepage files in /var/www/html https://caddyserver.com/docs/caddyfile/directives/root#examples https://caddy.community/t/help-getting-started-with-caddyserver-sveltekit-app/19346/6
        services.caddy = {
            enable = true;
            virtualHosts."localhost".extraConfig = ''
                respond "Hello, world!"
            '';
        };
    
    };

}

