{ inputs, lib, config, pkgs, ... }: {

    # TODO disko config
    #imports = [ ./server-hardware.nix ];

    js.sops.enable = true;
    js.server = {

        enable = true;
        openFirewall = true; # openFirewall != port forwarded, only accessible to internal network

        # Remote access
        ssh.enable = true;
        tarpits.enable = true;

        # Monitoring
        prometheus.exporters.node.enable = true;
        prometheus.exporters.comin.enable = true;
        loki.agents.promtail.enable = true;

        # 3d printer stuff
        klipper.enable = true;
        moonraker.enable = true;
        fluidd.enable = true;

    };

    # Set system name
    networking.hostName = "pastificio";

    # Setup static IP and default gateway
    networking.defaultGateway = "10.10.22.1";
    networking.interfaces.wlan0.ipv4.addresses = [{
        address = "10.10.22.19";
        prefixLength = 24;
    }];

}

