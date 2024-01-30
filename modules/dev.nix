{ inputs, config, pkgs, ... }:

{
    
    # System packages
    environment.systemPackages = with pkgs; [

        # Git
        git
        git-credential-manager

        # Java
        maven
        semeru-bin-16
        temurin-bin-17

        # JS
        nodejs_21
        yarn-berry

        # Rust
        rustup # includes cargo
        jetbrains.rust-rover # No flatpak yet

        # Misc
        etcher
        vial

    ];

    # Flatpak config
    services.flatpak.packages = [
        "flathub-beta:app/com.github.akiraux.akira//beta"
        "flathub:app/com.jetbrains.IntelliJ-IDEA-Community//stable"
        "flathub:app/com.jetpackduba.Gitnuro//stable"
        "flathub:app/com.vscodium.codium//stable"
        "flathub:app/org.gaphor.Gaphor//stable"
    ];

    programs.git = {
        enable = true;
        config.credential.credentialStore = "cache";
    };

}
