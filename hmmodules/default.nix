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

    # Flatpak config
    # TODO wayland by default
    services.flatpak = lib.mkIf osConfig.js.programs.desktop.enable {

        # Add repo
        remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        # If we add Flatseal on the system, it can't see user packages
        packages = [
            "flathub:app/com.github.tchx84.Flatseal//stable"
        ];

    };

}

