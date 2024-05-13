{ inputs, lib, config, pkgs, ... }: {

    # Autoupdate.
    #js.autoUpdate.enable = true;
    #js.autoUpdate.system.rebuildCmd = "switch";

    js.sops.enable = true;
    js.server = {
    
        enable = true;
        openFirewall = true; # openFirewall != port forwarded, only accessible to internal network
        
        caddy.enable = true;
        caddy.openFirewall = true; # we want this to be true even when disabling everything else

        authentik.enable = true;
        authentik.hostName = "auth.localhost";

        grafana.enable = true;
        grafana.hostName = "grafana.localhost";

        loki.enable = true;
        prometheus.enable = true;

        outline.enable = true;
        outline.hostName = "outline.localhost";

        seafile.enable = true;
        seafile.hostName = "files.localhost";
        
    };

    # Set system name
    networking.hostName = "justinhs-server";

}

