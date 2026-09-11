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
            #jetbrains.idea-oss
            jetbrains.rust-rover
            jetbrains.webstorm

            # Java
            maven

            # JS
            #yarn-berry

            # Rust
            rustup # includes cargo

            # Misc
            caligula # burn isos
            nixd
            prusa-slicer
            tio
            vial
            virtualbox
            winboat

        ];

        programs.git = {
            enable = true;
            config.credential.credentialStore = "cache";
            config.init.defaultBranch = "main";
        };

        # enable podman, required for winboat
        # more secure than docker since you can use it rootless
        # https://wiki.nixos.org/wiki/Podman
        virtualisation.podman = {
            enable = true;
            dockerCompat = true; # Creates a symlink from docker to podman
            defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
        };

    };

}
