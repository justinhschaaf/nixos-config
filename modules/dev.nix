{ inputs, config, pkgs, ... }:

{

    imports = [ 
        # Declarative flatpaks
        inputs.flatpaks.nixosModules.default
    ];

    # Flatpak config
    services.flatpak = {

        # Enable and add repo
        enable = true;
        remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        packages = [
            "flathub:com.jetbrains.IntelliJ-IDEA-Community//stable"
            "flathub:com.jetpackduba.Gitnuro//stable"
            "flathub:com.visualstudio.code//stable"
            "flathub:org.gaphor.Gaphor//stable"
        ];

    };

}
