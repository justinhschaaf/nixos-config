{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./backup.nix
        ./disks.nix
        ./killif.nix
        ./oom.nix
        ./sops.nix
        ./update.nix
    ];

}
