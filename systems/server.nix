{ inputs, lib, config, pkgs, ... }: {

    # Autoupdate.
    #js.autoUpdate.enable = true;
    #js.autoUpdate.system.rebuildCmd = "switch";

    js.sops.enable = true;
    js.server = {
    
        enable = true;
        openFirewall = false; # openFirewall != port forwarded, only accessible to internal network
        
        ssh.enable = true;
        ssh.openFirewall = true;

        tarpits.enable = true;
        tarpits.openFirewall = true;

        prometheus.enable = true;
        prometheus.exporters.node.enable = true;
        prometheus.scrapeFrom = { # local exporters
            "node-${config.networking.hostName}" = "127.0.0.1:${toString config.services.prometheus.exporters.node.port}";
            "authentik-${config.networking.hostName}" = "127.0.0.1:9300";
        };

        loki.enable = true;
        loki.agents.promtail.enable = true;
        
        caddy.enable = true;
        caddy.openFirewall = true; # we want this to be true even when disabling everything else

        authentik.enable = true;
        authentik.openFirewallMetrics = true;
        authentik.hostName = "auth.localhost";

        grafana.enable = false; # enable when OIDC is set up
        grafana.hostName = "grafana.localhost";

        outline.enable = false; # enable when OIDC is set up
        outline.hostName = "outline.localhost";

        seafile.enable = false; # waiting for https://github.com/NixOS/nixpkgs/pull/318727 to complete because database system is changing
        seafile.hostName = "files.localhost";
        
    };

    # Set system name
    networking.hostName = "tortelli";

}

