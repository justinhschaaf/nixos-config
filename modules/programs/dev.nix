{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.dev.enable = lib.mkEnableOption "dev tools";
    };

    config = lib.mkIf config.js.programs.dev.enable {
    
        # System packages
        environment.systemPackages = with pkgs; [

            # Let us actually write to Git
            git-credential-manager
            gitnuro

            # Editors
            jetbrains.idea-community
            jetbrains.rust-rover
            vscodium # I fucking hate vscode and that there's nothing better for free

            # Java
            maven

            # JS
            nodePackages.nodejs
            yarn-berry

            # Rust
            rustup # includes cargo

            # Misc
            #etcher # https://github.com/NixOS/nixpkgs/pull/295853
            gnome.gnome-boxes
            vial

        ];

        programs.git = {
            enable = true;
            config.credential.credentialStore = "cache";
            config.init.defaultBranch = "main";
        };

    };

}

