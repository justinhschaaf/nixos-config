{ inputs, lib, config, pkgs, ... }: {

    imports = [ ./server-hardware.nix ];

    # Autoupdate.
    #js.autoUpdate.enable = true;
    #js.autoUpdate.system.rebuildCmd = "switch";

    js.sops.enable = true;
    js.server = {
    
        enable = true;
        openFirewall = true; # openFirewall != port forwarded, only accessible to internal network
        
        ssh.enable = true;
        ssh.openFirewall = true;

        tarpits.enable = true;
        tarpits.openFirewall = true;

        prometheus.enable = true;
        prometheus.exporters.node.enable = true;
        prometheus.scrapeFrom = { # local exporters
            "node-${config.networking.hostName}" = "127.0.0.1:${toString config.services.prometheus.exporters.node.port}";
            "authentik-${config.networking.hostName}" = "127.0.0.1:9300";
            "caddy-${config.networking.hostName}" = "127.0.0.1:2019";
        };

        loki.enable = true;
        loki.agents.promtail.enable = true;
        
        caddy.enable = true;
        caddy.openFirewall = true; # we want this to be true even when disabling everything else

        waffles.lol.enable = false; # still working on getting yarn v2 packages working
        waffles.lol.hostName = "waffles.lol";

        authentik.enable = true;
        authentik.hostName = "auth.waffles.lol";
        authentik.ldap.enable = true;
        authentik.ldap.openFirewall = false; # only insecure ports are open and those don't even work right

        grafana.enable = false; # enable when OIDC is set up
        grafana.hostName = "grafana.waffles.lol";

        outline.enable = false; # enable when OIDC is set up
        outline.hostName = "outline.waffles.lol";

        seafile.enable = false; # waiting for https://github.com/NixOS/nixpkgs/pull/318727 to complete because database system is changing
        seafile.hostName = "files.waffles.lol";
        
    };

    # Add Fluidd
    # TODO implement a better solution for proxying applications over Authentik
    services.caddy.virtualHosts."fluidd.waffles.lol".extraConfig = ''
        route {
            # always forward outpost path to actual outpost
            reverse_proxy /outpost.goauthentik.io/* 127.0.0.1:9000

            # forward authentication to outpost
            forward_auth 127.0.0.1:9000 {
                uri /outpost.goauthentik.io/auth/caddy

                # capitalization of the headers is important, otherwise they will be empty
                copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version

                # optional, in this config trust all private ranges, should probably be set to the outposts IP
                trusted_proxies private_ranges
            }

            # actual site configuration below, for example
            reverse_proxy 10.10.22.19
        }
    '';

    # Set system name
    networking.hostName = "tortelli";

    # Setup static IP and default gateway
    networking.defaultGateway = "10.10.22.1";
    networking.interfaces.enp2s0.ipv4.addresses = [{
        address = "10.10.22.20";
        prefixLength = 24;
    }];

}

