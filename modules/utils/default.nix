{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./backup.nix
        ./sops.nix
        ./update.nix
    ];
    
}
