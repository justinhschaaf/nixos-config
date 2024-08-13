{ inputs, lib, config, pkgs, ... }: {

    imports = [ 
        inputs.microvm.nixosModules.host
    ];

    options.js.server.cluster = {
    
        enable = lib.mkEnableOption "special options for running a VM cluster";
        
        guests.all = lib.mkOption { type = lib.types.listOf (config.options.js.server.cluster.guest.options.type); };
        guests.config = lib.mkOption { type = lib.types.functionTo lib.types.attrs; }; # takes the guest config as an arg
        guests.ips = lib.mkOption { default = lib.attrsets.catAttrs "ip" config.js.server.cluster.guests.all; };
        
        guest.enable = lib.mkEnableOption "cluster child options. Only enable this inside the actual guest VM.";
        guest.options = lib.mkOption {
            type = lib.types.attrsOf lib.types.submodule {
                hostName = lib.mkOption { type = lib.types.str; };
                ip = lib.mkOption { type = lib.types.str; };
                master = lib.mkOption { type = lib.types.bool; default = false; };
            };
        };
        
        host.enable = lib.mkEnableOption "cluster host options";
        host.ip = lib.mkOption { default = "10.0.0.10"; };
        
    };


    config = lib.mkIf config.js.server.cluster.enable {

        # Setup network bridge
        systemd.network = if config.js.server.cluster.host.enable then {

            enable = true;

            netdevs."10-microvm".netdevConfig = {
                Kind = "bridge";
                Name = "microvm";
            };
            
            networks."10-microvm" = {
                matchConfig.Name = "microvm";
                networkConfig.Address = "${config.js.server.cluster.host.ip}/24";
            };
    
        } else if config.js.server.cluster.guest.enable then {
        
            enable = true;
            
            networks."11-microvm" = {
                matchConfig.Name = "vm-*";
                networkConfig.Bridge = "microvm";
                networkConfig.Address = "${config.js.server.cluster.guest.ip}/24";
            };
            
        } else {};

        # set hostname if we already know it
        networking.hostName = lib.mkIf config.js.server.cluster.guest.enable (lib.mkDefault config.js.server.cluster.guest.hostName);

        # override core defaults for cluster clients
        boot.loader.grub.enable = lib.mkIf config.js.server.cluster.guest.enable (lib.mkForce false); # we're in a vm we don't need it
        networking.networkmanager.enable = lib.mkIf config.js.server.cluster.guest.enable (lib.mkForce false); # using systemd.network instead
        js.autoUpdate.firmware.enable = lib.mkIf config.js.server.cluster.guest.enable false; # there is no firmware in a vm

        # make microvms
        microvm.host.enable = config.js.server.cluster.host.enable;
        microvm.vms = lib.listToAttrs (lib.lists.forEach config.js.server.cluster.guests (guest: {
            name = guest.hostName;
            value = config.js.server.cluster.guest.config guest;
        }));

        # caddy load balancer https://www.linuxtrainingacademy.com/caddy-load-balancing-tutorial/
        services.caddy.virtualHosts.":80".extraConfig =
            lib.mkIf (config.js.server.caddy.enable && config.js.server.cluster.host.enable) ''
                reverse_proxy ${lib.strings.concatStringsSep " " config.js.server.cluster.guests.ips} {
                    lb_policy least_conn
                }
            '';
    
    };

}

