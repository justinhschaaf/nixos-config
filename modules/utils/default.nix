{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./autoupdate.nix
        ./backup.nix
        ./sops.nix
    ];
    
}
