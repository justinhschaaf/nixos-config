{ inputs, lib, config, pkgs, ... }: {

    imports = [ 
        ./authentik.nix
        ./caddy.nix
        ./grafana.nix
        ./prometheus.nix
        ./seafile.nix
    ];

    options = {
        js.server.enable = lib.mkEnableOption "server defaults";
        js.server.openFirewall = lib.mkOption { default = false; };
    };

    config = lib.mkIf config.js.server.enable {

        # Enable SSH
        services.openssh = {
            enable = true;
            ports = [ 2720 ];
            openFirewall = true;
            settings.UseDns = true;
            settings.PermitRootLogin = "no";
        };

        # Tarpits to fuck with attackers
        services.endlessh-go = {
            enable = true;
            port = 22;
            openFirewall = true;
        };
    
    };

}

