{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./backup.nix
        ./disks.nix
        ./sops.nix
        ./update.nix
    ];

}
