{ inputs, lib, config, pkgs, ... }: {

    # Autoupdate.
    #js.autoUpdate.enable = true;
    #js.autoUpdate.system.rebuildCmd = "switch";

    js.sops.enable = true;
    js.server = {
    
        enable = true;
        caddy.enable = true;

        authentik.enable = true;
        authentik.hostName = "auth.localhost";

        seafile.enable = true;
        seafile.hostName = "files.localhost";
        
    };

    # Set system name
    networking.hostName = "justinhs-server";

}

