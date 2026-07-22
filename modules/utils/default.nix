{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./backup.nix
        ./disks.nix
        ./oom.nix
        ./sops.nix
        ./update.nix
    ];

}
