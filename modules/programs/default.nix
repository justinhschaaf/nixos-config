{ inputs, lib, config, pkgs, ... }: {

    imports = [

        # These can be imported here and not imported in subsequent modules
        # Importing in subsequent modules causes an "already declared" error

        # Declarative flatpaks
        inputs.flatpaks.nixosModules.default

        # Our other modules
        ./desktop.nix
        ./dev.nix
        ./gaming.nix
        ./thunar.nix
        ./tui.nix

    ];

}
