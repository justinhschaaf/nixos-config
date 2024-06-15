{ inputs, lib, config, hostCfg, guest, ... }: {

    js.server = { # TODO add hostnames for services
    
        enable = true;
        
        ssh.enable = true;
        ssh.openFirewall = true;
        
        tarpits.enable = true;
        tarpits.openFirewall = true;
        
        prometheus.exporters.node.enable = true;
        prometheus.exporters.node.openFirewall = true;

        loki.agents.promtail.enable = true;
        loki.agents.promtail.client = "http://${js.server.cluster.host.ip}:${toString hostCfg.services.loki.configuration.server.http_listen_port}";
        
        cluster.enable = true;
        cluster.guest.enable = true;
        cluster.host.ip = hostCfg.js.server.cluster.host.ip;
        
        caddy.enable = true;
        caddy.openFirewall = true;

        authentik.enable = true;
        authentik.openFirewallMetrics = true;
        authentik.hostName = "auth.localhost";

        grafana.enable = false; # enable when OIDC is set up
        grafana.hostName = "grafana.localhost";

        outline.enable = false; # enable when OIDC is set up
        outline.hostName = "outline.localhost";

        seafile.enable = true;
        seafile.hostName = "files.localhost";
        
    };

    microvm.hypervisor = "cloud-hypervisor";
    microvm.mem = 4096;

    # Share Nix Store and Sops secrets
    microvm.shares = [{
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
    } {
        source = "/run/secrets";
        mountPoint = "/run/secrets";
        securityModel = "mapped-file";
        proto = "virtiofs";
    }];

    networking.hostName = guest.hostName;
    systemd.network.networks."11-microvm" = {
        matchConfig.Name = "vm-*";
        networkConfig.Bridge = "microvm";
        networkConfig.Address = "${guest.ip}/24";
    };

}

