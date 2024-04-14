{ inputs, lib, config, pkgs, ... }: {

    imports = [ 

        # These can be imported here and not imported in subsequent modules
        # Importing in subsequent modules causes an "already declared" error

        # Import home manager so we can manage home
        inputs.home-manager.nixosModules.home-manager 

        # Other modules
        ./fonts.nix
        ./hyprland.nix
        ./jpkb.nix
        ./nvidia.nix

    ];

    options = {
        js.desktop.enable = lib.mkEnableOption "features you'd expect from a desktop environment";
    };

    config = lib.mkIf config.js.desktop.enable {

        # greetd, declare multiple sessions as per https://github.com/apognu/tuigreet?tab=readme-ov-file#sessions
        services.greetd = {
            enable = true;
            settings = {
                default_session = let 
                    cmd = if config.js.desktop.hyprland.enable
                        # yes, the Hyprland command starts with a capital letter https://wiki.hyprland.org/Nix/
                        then "--cmd Hyprland"
                        else "";
                in {
                    command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --time --user-menu ${cmd}";
                };
            };
        };

        # Enable touchpad support (enabled default in most desktopManager).
        services.xserver.libinput.enable = true;

        # Enable CUPS to print documents.
        services.printing.enable = true;

        # Enable udisks2 for udiskie
        services.udisks2.enable = true;
        services.udisks2.mountOnMedia = true;

        # Enable sound with pipewire.
        sound.enable = true;
        hardware.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            # If you want to use JACK applications, uncomment this
            jack.enable = true;

            # use the example session manager (no others are packaged yet so this is enabled by default,
            # no need to redefine it in your config for now)
            #media-session.enable = true;
        };

        # Enable flatpaks here, not anywhere else!
        services.flatpak.enable = true;

        # Allow unprivileged users to create namespaces. It's recommended to keep
        # this off when using linux_hardened for security, but it's necessary for
        # Flatpaks to work. Previously found in core.
        security.unprivilegedUsernsClone = true;

        # General Home Manager config
        home-manager = {
            extraSpecialArgs = { inherit inputs; };
            sharedModules = [ inputs.self.outputs.homeManagerModules.default ];
            useGlobalPkgs = true;
            useUserPackages = true;
        };

        # GNOME apps depend on global config
        # Keeping this here since it'll be used for gnome apps in every environment
        # https://nixos.wiki/wiki/GNOME#Running_GNOME_programs_outside_of_GNOME
        programs.dconf.enable = true;

        # Tell GTK apps to use dark mode
        # This feels more natural than putting it in the user file
        # Plus this MUST be system-side or it doesn't work...
        environment.sessionVariables.GTK_THEME = "Adwaita:dark";

        # Install desktop programs too by default
        js.programs.desktop.enable = lib.mkDefault true;

        # Enable fonts by default
        js.desktop.fonts.enable = lib.mkDefault true;

    };

}
