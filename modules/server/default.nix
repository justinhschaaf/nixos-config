{ inputs, lib, config, pkgs, ... }: {

    imports = [ 

        inputs.microvm.nixosModules.host
    
        ./data
        ./monitoring
        ./services
        ./cluster.nix
        
    ];

    options.js.server = {
        enable = lib.mkEnableOption "server defaults";
        openFirewall = lib.mkOption { default = false; };
        ssh.enable = lib.mkEnableOption "SSH";
        ssh.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
        tarpits.enable = lib.mkEnableOption "tarpits for malicious actors";
        tarpits.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    # Enable SSH
    config.services.openssh = lib.mkIf config.js.server.ssh.enable {
        enable = true;
        ports = [ 2720 ];
        openFirewall = config.js.server.ssh.openFirewall;
        settings.UseDns = true;
        settings.PermitRootLogin = "no";
    };

    # Tarpits to fuck with attackers
    config.services.endlessh-go = lib.mkIf config.js.server.tarpits.enable {
        enable = true;
        port = 22;
        openFirewall = config.js.server.tarpits.openFirewall;
    };

}

