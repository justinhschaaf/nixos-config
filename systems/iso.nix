{ inputs, lib, config, pkgs, modulesPath, ... }: {

    # start with the minimal installer defaults
    # https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD
    # https://haseebmajid.dev/posts/2024-02-04-how-to-create-a-custom-nixos-iso/
    imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
        (modulesPath + "/installer/cd-dvd/channel.nix")
    ];

    # add the jsinstall command
    environment.systemPackages = [ inputs.self.outputs.packages.${pkgs.system}.jsinstall ];

    # set nixpkgs platform
    nixpkgs.hostPlatform = "x86_64-linux";

    # disable iwd for legacy wifi card support
    js.network.nm.enable = false;

    # set default passwords
    users.users.nixos.password = "nixos";
    users.users.root.password = "nixos";

    # Set system name
    networking.hostName = "nixos-iso";

}
