{ inputs, lib, config, pkgs, ... }: {

    # Autoupdate.
    #js.autoUpdate.enable = true;

    js.server.enable = true;

    # Set system name
    networking.hostName = "justinhs-server";

}

