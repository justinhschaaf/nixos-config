{ inputs, config, pkgs, ... }: {
    
    imports = [

        # Import default configs so flakes know how to behave by default
        inputs.anyrun.homeManagerModules.default
        inputs.flatpaks.homeManagerModules.default

        # Import other modules
        ./hyprland.nix
        ./mimetypes.nix
        ./terminal.nix
        ./theme.nix
        
    ];

}

