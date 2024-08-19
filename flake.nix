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
        flatpaks.url = "github:GermanBread/declarative-flatpak/stable"; 
        flatpaks.inputs.nixpkgs.follows = "nixpkgs";

        #
        # SYSTEM
        #

        # Home Manager
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        # Declarative VMs
        microvm.url = "github:astro/microvm.nix";
        microvm.inputs.nixpkgs.follows = "nixpkgs";

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

    };

    outputs = { nixpkgs, ... }@inputs: # TODO play around with `self` keyword
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        jspkgs = import inputs.jspkgs { inherit system; };
        #guests = [{
        #    hostName = "tortellini";
        #    ip = "10.0.0.20";
        #    master = true;
        #} {
        #    hostName = "tortellacci";
        #    ip = "10.0.0.30";
        #} {
        #    hostName = "tortelloni";
        #    ip = "10.0.0.40";
        #}];
    in nixpkgs.lib.attrsets.recursiveUpdate {

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
                ./users/justinhs.nix
            ];
        };

        # Homelab Server - Exprimental VM Cluster
        #nixosConfigurations.tortelli-cluster = nixpkgs.lib.nixosSystem {
        #    specialArgs = { inherit inputs system jspkgs guests; };
        #    modules = [
        #        ./hardware-configuration.nix
        #        ./modules
        #        ./systems/server-cluster.nix
        #        ./users/justinhs.nix
        #    ];
        #};

        homeManagerModules.default = ./hmmodules;

    } {

        # This currently doesn't work because nixosConfigurations doesn't exist to set hostCfg to when this is ran
        # Server Cluster Nodes
        #nixosConfigurations = let
        #    hostCfg = inputs.self.outputs.nixosConfigurations.tortelli-cluster;
        #    nixosCfg = guest: nixpkgs.lib.nixosSystem {
        #        specialArgs = { inherit inputs system jspkgs hostCfg guest; };
        #        modules = [
        #            ./modules
        #            ./systems/server-guest.nix
        #        ];
        #    };
        #in nixpkgs.lib.attrsets.genAttrs nixosCfg (nixpkgs.lib.attrsets.catAttrs "hostName" guests);
        
    };
    
}

