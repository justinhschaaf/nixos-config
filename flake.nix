{

  # GOALS:
  #
  # - [ ] Have this file hosted in a GitHub repo justinhschaaf/nixos-config
  # - [ ] Actually comment shit so I know what it does
  # - [ ] Have a local flake that uses system.autoUpgrade to automatically update the system from the remote flake
  # - [ ] Perhaps have separate configs for each machine defined, need some way to specify which profile to build
  # - [ ] Host eww in a separate GitHub repo and have it auto pull upon rebuilding the system
  # - [ ] Use the on-disk hardware-configuration.nix instead of having to pull it from GitHub
  # - [ ] Setup Home Manager
  # - [ ] Configure hyprland through home manager
  # - [ ] Declarative Flatpaks

  description = "A very basic flake";

  inputs = {
  	nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {

    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    # packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    	specialArgs = { inherit system; };
    	modules = [ ./configuration.nix ];
    };

  };
}
