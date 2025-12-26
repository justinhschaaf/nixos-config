{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.dev.enable = lib.mkEnableOption "dev tools";
    };

    config = lib.mkIf config.js.programs.dev.enable {

        # System packages
        environment.systemPackages = with pkgs; [

            # Let us actually write to Git
            git-credential-manager
            gitui
            gh

            # Editors
            jetbrains.idea
            jetbrains.rust-rover
            jetbrains.webstorm

            # Java
            maven

            # JS
            nodePackages.nodejs
            yarn-berry

            # Rust
            rustup # includes cargo

            # Misc
            activitywatch
            usbimager
            gnome-boxes
            nixd
            prusa-slicer
            tio
            vial

        ];

        programs.git = {
            enable = true;
            config.credential.credentialStore = "cache";
            config.init.defaultBranch = "main";
        };

    };

}

