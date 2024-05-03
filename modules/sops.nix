{ inputs, lib, config, pkgs, ... }: {

    imports = [ inputs.sops-nix.nixosModules.sops ];

    options = {
        # Usage note: remember to set sops.age.keyFile
        js.sops.enable = lib.mkEnableOption "secrets management with sops-nix";
    };

    config = lib.mkIf config.js.sops.enable {

        environment.systemPackages = with pkgs; [
            age
            sops
        ];

        sops.defaultSopsFormat = "yaml";
    
    };

}

