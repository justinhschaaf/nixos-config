{ inputs, config, pkgs, ... }:

{

    # Flatpak config
    services.flatpak.packages = [
        "flathub:app/com.jetbrains.IntelliJ-IDEA-Community//stable"
        "flathub:app/com.jetpackduba.Gitnuro//stable"
        "flathub:app/com.vscodium.codium//stable"
        "flathub:app/org.gaphor.Gaphor//stable"
    ];

}
