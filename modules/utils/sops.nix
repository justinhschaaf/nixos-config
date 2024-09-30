{ inputs, lib, config, pkgs, ... }: {

    imports = [ inputs.sops-nix.nixosModules.sops ];

    options = {
        js.sops.enable = lib.mkEnableOption "secrets management with sops-nix";
    };

    config = lib.mkIf config.js.sops.enable {

        environment.systemPackages = with pkgs; [
            age
            sops
        ];

        sops.defaultSopsFormat = "yaml";
        sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    
    };

}

