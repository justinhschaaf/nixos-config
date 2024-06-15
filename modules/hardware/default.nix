{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./fingerprint.nix
        ./nvidia.nix
    ];
    
}

