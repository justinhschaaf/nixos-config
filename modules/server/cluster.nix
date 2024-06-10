{ inputs, lib, config, pkgs, ... }: {

    imports = [ 
        inputs.microvm.nixosModules.host
    ];

    options.js.server.cluster = {
    
        enable = lib.mkEnableOption "special options for running a VM cluster";
        
        nodes = lib.mkOption { type = lib.types.listOf (lib.types.attrsOf lib.types.submodule {
            hostName = lib.mkOption { type = lib.types.str; };
            ip = lib.mkOption { type = lib.types.str; };
            master = lib.mkOption { type = lib.types.bool; default = false; };
        }); };
        
        node.enable = lib.mkEnableOption "cluster child options. Only enable this inside the actual node VM.";
        node.config = lib.mkOption { type = lib.types.functionTo lib.types.attrs; }; # takes the node config as an arg
        node.ips = lib.mkOption { default = lib.attrsets.catAttrs "ip" config.js.server.cluster.nodes; };
        
        host.enable = lib.mkEnableOption "cluster host options";
        host.ip = lib.mkOption { default = "10.0.0.10"; };
        
    };


    config = lib.mkIf config.js.server.cluster.enable {

        # Setup network bridge
        systemd.network = if config.js.server.cluster.host.enable {

            enable = true;

            netdevs."10-microvm".netdevConfig = {
                Kind = "bridge";
                Name = "microvm";
            };
            
            networks."10-microvm" = {
                matchConfig.Name = "microvm";
                networkConfig.Address = "${config.js.server.cluster.host.ip}/24";
            };
    
        } else if config.js.server.cluster.node.enable {
            enable = true;
        } else {};

        # override core defaults for cluster clients
        boot.loader.grub.enable = lib.mkIf config.js.server.cluster.node.enable (lib.mkForce false); # we're in a vm we don't need it
        networking.networkmanager.enable = lib.mkIf config.js.server.cluster.node.enable (lib.mkForce false); # using systemd.network instead
        js.autoUpdate.firmware.enable = lib.mkIf config.js.server.cluster.node.enable false;

        # make microvms
        microvm.host.enable = config.js.server.cluster.host.enable;
        microvm.vms = listToAttrs (lib.lists.forEach config.js.server.cluster.nodes (node: {
            name = node.hostName;
            value = config.js.server.cluster.node.config node;
        }));

        # caddy load balancer https://www.linuxtrainingacademy.com/caddy-load-balancing-tutorial/
        services.caddy.virtualHosts.":80".extraConfig =
            lib.mkIf (config.js.server.caddy.enable && config.js.server.cluster.host.enable) ''
                reverse_proxy ${lib.strings.concatStringsSep " " js.server.cluster.node.ips} {
                    lb_policy least_conn
                }
            '';
    
    };

}

