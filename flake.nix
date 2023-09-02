{

    description = "A very basic flake";

    inputs = {

        # Packages
  	    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        # Home Manager
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Hyprland, even though it's in the repos we have to do this because flake
        hyprland.url = "github:hyprwm/Hyprland";

        # anyrun https://github.com/Kirottu/anyrun
        anyrun = {
            url = "github:Kirottu/anyrun";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Declarative flatpaks
        flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    };

    outputs = { self, nixpkgs, ... }@inputs:
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

        nixosConfigurations.justinhs-tv = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system; };
            modules = [ 
                ./hardware-configuration.nix 
                ./configs/configuration.nix 
                { networking.hostName = "justinhs-tv"; } 
            ];
        };

    };
    
}
