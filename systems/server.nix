{ inputs, lib, config, pkgs, ... }: {

    imports = [ ./server-hardware.nix ];

    # Enable Intel CPU support
    js.hardware.intel.cpu.enable = true;

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
            "comin-${config.networking.hostName}" = "127.0.0.1:${toString config.services.comin.exporter.port}";
            "authentik-${config.networking.hostName}" = "127.0.0.1:9300";
            "caddy-${config.networking.hostName}" = "127.0.0.1:2019";
        };

        loki.enable = true;
        loki.agents.promtail.enable = true;

        caddy.enable = true;
        caddy.openFirewall = true; # we want this to be true even when disabling everything else

        waffles.lol.enable = true;
        waffles.lol.hostName = "waffles.lol";

        authentik.enable = true;
        authentik.hostName = "auth.waffles.lol";
        authentik.openFirewall = true;
        authentik.ldap.enable = true;
        authentik.ldap.openFirewall = true;
        authentik.radius.enable = true;

        grafana.enable = true;
        grafana.hostName = "grafana.waffles.lol";

        guacamole.enable = true;
        guacamole.hostName = "guac.waffles.lol";

        kasmweb.enable = true;
        kasmweb.hostName = "kasm.waffles.lol";

        outline.enable = true;
        outline.hostName = "kb.waffles.lol";

        pigweb.enable = true;
        pigweb.hostName = "pigs.waffles.lol";

        unifi.enable = true;
        unifi.hostName = "unifi.${config.services.avahi.hostName}.${config.services.avahi.domainName}";
        unifi.openFirewallConsole = true;
        unifi.openFirewallDiscovery = true;

        youtrack.enable = true;
        youtrack.hostName = "youtrack.waffles.lol";

    };

    # Set system name
    networking.hostName = "tortelli";

    # Setup static IP and default gateway
    networking.defaultGateway = "10.10.22.1";
    networking.interfaces.enp2s0.ipv4.addresses = [{
        address = "10.10.22.20";
        prefixLength = 24;
    }];

}

