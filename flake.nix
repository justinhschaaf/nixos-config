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
            "https://anyrun.cachix.org"
        ];

        trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        ];

    };

    inputs = {

        #
        # PACKAGES
        #

        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        # justinhs packages
        jspkgs.url = "github:justinhschaaf/nix-packages/main";
        jspkgs.inputs.nixpkgs.follows = "nixpkgs";

        # Declarative flatpaks
        flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
        flatpaks.inputs.nixpkgs.follows = "nixpkgs";

        #
        # SYSTEM
        #

        # Home Manager
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        # Secrets management
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";

        #
        # APPLICATIONS
        #

        # anyrun https://github.com/Kirottu/anyrun
        anyrun.url = "github:Kirottu/anyrun";
        anyrun.inputs.nixpkgs.follows = "nixpkgs";

        # Authentik Server
        # Override poetry2nix to fix https://github.com/nix-community/authentik-nix/issues/30
        poetry2nix.url = "github:nix-community/poetry2nix";
        authentik-nix.url = "github:nix-community/authentik-nix";
        authentik-nix.inputs.nixpkgs.follows = "nixpkgs";
        authentik-nix.inputs.poetry2nix.follows = "poetry2nix";

        # waffles.lol website
        #waffleslol.url = "path:/mnt/Files/Programming/waffles.lol";
        #waffleslol.inputs.nixpkgs.follows = "nixpkgs";

    };

    outputs = { nixpkgs, ... }@inputs: # TODO play around with `self` keyword
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        jspkgs = import inputs.jspkgs { inherit system; };
    in {

        nixosConfigurations.justinhs-go = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [ 
                ./hardware-configuration.nix 
                ./modules
                ./systems/go.nix
                ./users/justinhs.nix
            ];
        };

        nixosConfigurations.justinhs-tv = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [ 
                ./hardware-configuration.nix 
                ./modules
                ./systems/tv.nix
                ./users/justinhs.nix
            ];
        };

        # Homelab Server
        nixosConfigurations.tortelli = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [
                ./hardware-configuration.nix
                ./modules
                ./systems/server.nix
                ./users/sysadmin.nix
            ];
        };

        homeManagerModules.default = ./hmmodules;

    };
    
}

