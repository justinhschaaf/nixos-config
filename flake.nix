{

    description = "A very basic flake";

    # Nix settings
    nixConfig = {

        # Enable Flakes
        experimental-features = [ "nix-command" "flakes" ];

        # Enable binary caching so the flake stuff isn't constantly recompiled
        accept-flake-config = true;
        builders-use-substitutes = true;

        substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org/"
            "https://anyrun.cachix.org"
            "https://cache.garnix.io"
            "https://hyprland.cachix.org"
        ];

        trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
            "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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

        #
        # SYSTEM
        #

        # Updates
        comin.url = "github:nlewo/comin";

        # Disko disk partitioning
        disko.url = "github:nix-community/disko/latest";
        disko.inputs.nixpkgs.follows = "nixpkgs";

        # Home Manager
        home-manager.url = "github:nix-community/home-manager";

        # Special hardware configs
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";

        # Secrets management
        sops-nix.url = "github:Mic92/sops-nix";

        #
        # APPLICATIONS
        #

        # anyrun https://github.com/Kirottu/anyrun
        anyrun.url = "github:Kirottu/anyrun";

        # Authentik Server
        authentik-nix.url = "github:nix-community/authentik-nix";

        # Patched Caddy containing Cloudflare plugin
        nixos-caddy.url = "github:Ramblurr/nixos-caddy";

        # Hyprland (must use the nix flake for split-monitor-workspaces)
        hyprland.url = "github:hyprwm/Hyprland";

        # Hyprland Split Monitor Workspaces Plugin
        split-monitor-workspaces.url = "github:Duckonaut/split-monitor-workspaces";
        split-monitor-workspaces.inputs.hyprland.follows = "hyprland";

        # waffles.lol website
        waffleslol.url = "github:justinhschaaf/waffles.lol";

    };

    outputs = { nixpkgs, ... }@inputs:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        jspkgs = import inputs.jspkgs { inherit system; };
    in {

        # Gaming PC
        nixosConfigurations.bucatini = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [
                ./modules
                ./systems/gaming.nix
                ./users/justinhs.nix
            ];
        };

        # Framework Laptop
        nixosConfigurations.farfalle = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [
                ./modules
                ./systems/laptop.nix
                ./users/justinhs.nix
            ];
        };

        # Bedroom TV
        nixosConfigurations.lasagna = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [
                ./modules
                ./systems/tv.nix
                ./users/sysadmin.nix
                ./users/marco.nix
            ];
        };

        # Homelab Server
        nixosConfigurations.tortelli = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs system jspkgs; };
            modules = [
                ./modules
                ./systems/server.nix
                ./users/sysadmin.nix
            ];
        };

        nixosModules.default = ./modules;
        homeManagerModules.default = ./hmmodules;

        # Dev Shell. This adds the jstestvm command for quickly building system vms
        devShells.${system}.default = pkgs.mkShell rec {
            buildInputs = [ inputs.self.outputs.packages.${system}.jstestvm ];
        };

        # Package scripts. THIS HAS TO BE DEFINED LIKE THIS, SEE BELOW
        # https://github.com/NixOS/nix/issues/916
        # https://old.reddit.com/r/NixOS/comments/16p7ea2/dynamic_attribute_x86_64linux_already_defined/k1skjsf/
        packages.${system} = {

            # Use trivial builders from https://ryantm.github.io/nixpkgs/builders/trivial-builders/

            jsbackup = pkgs.writeShellApplication {
                name = "jsbackup";
                runtimeInputs = with pkgs; [ rsync util-linux ];
                text = builtins.readFile ./scripts/backup.sh;
            };

            jsinstall = pkgs.writeShellApplication {
                name = "jsinstall";
                runtimeInputs = with pkgs; [ disko git nixos-install nixos-rebuild ];
                text = builtins.readFile ./scripts/install.sh;
            };

            jstestvm = pkgs.writeShellApplication {
                name = "jstestvm";
                runtimeInputs = with pkgs; [ nixos-rebuild ];
                text = builtins.readFile ./scripts/test.sh;
            };

        };

    };

}
