{ inputs, lib, config, pkgs, ... }: {

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
        authentik.ldap.enable = true;
        authentik.hostName = "auth.waffles.lol";

        grafana.enable = false; # enable when OIDC is set up
        grafana.hostName = "grafana.waffles.lol";

        outline.enable = false; # enable when OIDC is set up
        outline.hostName = "outline.waffles.lol";

        seafile.enable = false; # waiting for https://github.com/NixOS/nixpkgs/pull/318727 to complete because database system is changing
        seafile.hostName = "files.waffles.lol";
        
    };

    # Set system name
    networking.hostName = "tortelli";

}

