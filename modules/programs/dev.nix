{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.dev.enable = lib.mkEnableOption "dev tools";
    };

    config = lib.mkIf config.js.programs.dev.enable {
    
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
            #etcher # https://github.com/NixOS/nixpkgs/pull/295853
            vial

        ];

        # Flatpak config
        services.flatpak.packages = [
            "flathub:app/com.jetbrains.IntelliJ-IDEA-Community//stable"
            "flathub:app/com.jetpackduba.Gitnuro//stable"
            "flathub:app/com.vscodium.codium//stable"
            "flathub:app/org.gaphor.Gaphor//stable"
        ];

        programs.git = {
            enable = true;
            config.credential.credentialStore = "cache";
        };

    };

}
