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

    ];

    options = {
        js.desktop.enable = lib.mkEnableOption "features you'd expect from a desktop environment";
    };

    config = lib.mkIf config.js.desktop.enable {

        # greetd, you can add multiple sessions as per https://github.com/apognu/tuigreet?tab=readme-ov-file#sessions
        #
        # you don't have to though, as any package which provides passthru.providedSessions, defines .desktop files
        # for them, and is added to services.displayManager.sessionPackages will automatically show up here. where does
        # that get passed to the command here? i don't fucking know i'm too beaten to check rn. either way, anything
        # added to uwsm would automatically generate these .desktop files and use those; however, after
        # https://github.com/NixOS/nixpkgs/pull/474174 this is no longer the case. instead, hyprland itself started
        # providing a .desktop file for the uwsm session, and nixpkgs maintainers decided those were fine to use. the
        # massive problem with this is both the uwsm and non-uwsm .desktop files are loaded by the greeter, and the
        # default is the non-uwsm one (likely as it's first alphabetically, or malice idk fuck you). as far as i can
        # tell, there is no way to revert this change for my own flake, no way to get rid of/hide that non-uwsm
        # .desktop file, and no way to set the default wayland session .desktop file tuigreet (or most display managers)
        # use. as such, we add --remember-session to (theoretically) remember your last selection, but you're still
        # stuck having to change the session the first time you try to sign in. why? fuck you, i guess...
        #
        # why is it important we start hyprland with uwsm? good question. it properly starts systemd targets other
        # services depend on (most importantly graphical-session.target, used by waybar and wlsunset)
        #
        # this took roughly 2 hours to figure out and i can't even fully fix it. fml.
        services.greetd.enable = true;
        services.greetd.useTextGreeter = true;
        services.greetd.settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --asterisks --time --user-menu --remember-session";

        # Enable touchpad support (enabled default in most desktopManager).
        services.libinput.enable = true;

        # Enable CUPS to print documents.
        # https://wiki.nixos.org/wiki/Printing
        services.printing.enable = true;
        services.printing.drivers = with pkgs; [
            cups-browsed
            cups-filters
            foomatic-db-ppds
            foomatic-filters
        ];

        # Enable udisks2 for udiskie
        services.udisks2.enable = true;
        services.udisks2.mountOnMedia = true;

        # Enable sound with pipewire.
        services.pulseaudio.enable = false;
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

        # enable bluetooth
        hardware.bluetooth.enable = true;

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
            backupFileExtension = "BACKUP"; # fixes a bug where Home Manager refuses to start due to old files
        };

        # GNOME apps depend on global config
        # Keeping this here since it'll be used for gnome apps in every environment
        # https://wiki.nixos.org/wiki/GNOME#Running_GNOME_programs_outside_of_GNOME
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

