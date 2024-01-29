{

    description = "A very basic flake";

    # Nix settings
    nixConfig = {

        # Enable Flakes
        experimental-features = [ "nix-command" "flakes" ];

        # Enable binary caching so the flake stuff isn't constantly recompiled
        accept-flake-config = true;
        builders-use-substitutes = true;
        no-eval-cache = true; # https://github.com/NixOS/nix/issues/3872#issuecomment-1637052258

        substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org/"
            "https://hyprland.cachix.org"
            "https://anyrun.cachix.org"
        ];

        trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        ];

    }; 

    inputs = {

        # Packages
  	    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        # justinhs packages
        justinhs-packages = {
            url = "github:justinhschaaf/nix-packages/main";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Home Manager
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # anyrun https://github.com/Kirottu/anyrun
        anyrun = {
            url = "github:Kirottu/anyrun";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Declarative flatpaks
        flatpaks = { 
            url = "github:GermanBread/declarative-flatpak/stable"; 
            inputs.nixpkgs.follows = "nixpkgs";
        };

    };

    outputs = { self, nixpkgs, ... }@inputs:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        jspkgs = import justinhs-packages { inherit system; };
    in
    {

        # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
        # packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

        nixosConfigurations.justinhs-go = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [ 
                ./hardware-configuration.nix 
                ./modules/autoupdate.nix
                ./modules/core.nix
                ./modules/desktop.nix
                ./modules/dev.nix
                ./users/justinhs.nix
                { networking.hostName = "justinhs-go"; } 
            ];
        };

        nixosConfigurations.justinhs-tv = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [ 
                ./hardware-configuration.nix 
                ./modules/autoupdate.nix
                ./modules/core.nix
                ./modules/desktop.nix
                ./users/justinhs.nix
                { networking.hostName = "justinhs-tv"; } 
            ];
        };

    };
    
}
