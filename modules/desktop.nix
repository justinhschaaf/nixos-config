{ inputs, config, pkgs, ... }:

{

    imports = [ 

        # These can be imported here and not imported in subsequent modules
        # Importing in subsequent modules causes an "already declared" error

        # Import home manager so we can manage home
        inputs.home-manager.nixosModules.home-manager 

        # Declarative flatpaks
        inputs.flatpaks.nixosModules.default

        # Fonts
        ./fonts.nix

    ];

    # greetd, declare multiple sessions as per https://github.com/apognu/tuigreet?tab=readme-ov-file#sessions
    services.greetd = {
        enable = true;
        settings = {
            default_session = {
                # yes, the Hyprland command starts with a capital letter https://wiki.hyprland.org/Nix/
                command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --time --user-menu --cmd Hyprland";
            };
        };
    };

    # these don't work lmao
    # Make sure TTY2 is loaded, remember to re-add the lib import when uncommenting
    #systemd.services.greetd.unitConfig.After = lib.mkForce [
    #    "systemd-user-sessions.service"
    #    "plymouth-quit-wait.service"
    #    "getty@tty2.service" 
    #];

    # Make sure tuigreet doesn't get covered in logs https://github.com/apognu/tuigreet/issues/68#issuecomment-1586359960
    #systemd.services.greetd.serviceConfig = {

    #    Type = "idle";
    #    StandardInput = "tty";
    #    StandardOutput = "tty";
    #    StandardError = "journal"; # Without this errors will spam on screen

    #    # Without these bootlogs will spam on screen
    #    TTYPath = "/dev/tty2";
    #    TTYReset = true;
    #    TTYVHangup = true;
    #    TTYVTDisallocate = true;

    #};

    # Enable touchpad support (enabled default in most desktopManager).
    services.xserver.libinput.enable = true;

    # XDG Desktop Portal
    xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
            xdg-desktop-portal-gtk # Needed for file picker
            xdg-desktop-portal-hyprland # Needed for screen sharing
        ];
        config.common = {
            default = [ "hyprland" ];
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
        };
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Let us sign back in after locking the computer https://github.com/NixOS/nixpkgs/issues/143365
    security.pam.services.swaylock = {};

    # Enable GVFS and Tumbler for Thunar features
    services.gvfs.enable = true;
    services.tumbler.enable = true;

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

    # General Home Manager config
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        useGlobalPkgs = true;
        useUserPackages = true;
    };

    environment.systemPackages = [
        
        # Hyprland Stuff/Basic System Functionality
        pkgs.brightnessctl
        pkgs.eww
        pkgs.hyprland
        pkgs.libnotify
        pkgs.mako
        pkgs.polkit_gnome
        pkgs.swww
        pkgs.udiskie
        inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins
        # https://github.com/ErikReider/SwayOSD

        # Clipboard
        pkgs.wl-clipboard
        pkgs.wl-clipboard-x11
        pkgs.wl-clip-persist

        # Screenshots
        pkgs.grim
        pkgs.grimblast
        pkgs.hyprpicker
        pkgs.jq
        pkgs.satty
        pkgs.slurp

        # Sleep
        pkgs.sway-audio-idle-inhibit
        pkgs.swayidle
        pkgs.swaylock
        pkgs.graphicsmagick

        # File thumbnails
        pkgs.f3d
        pkgs.ffmpegthumbnailer
        pkgs.libgsf
        pkgs.poppler
        pkgs.webp-pixbuf-loader

        # Applications
        pkgs.kitty
        pkgs.gnome.gnome-system-monitor
        pkgs.gparted
        pkgs.wdisplays
        
    ];

    # Flatpak config
    services.flatpak = {

        # Turn on here, don't do anywhere else
        enable = true;

        # Add repo
        remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        remotes.flathub-beta = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        packages = [
            "flathub:app/app.drey.Warp//stable"
            "flathub:app/com.github.tchx84.Flatseal//stable"
            "flathub:app/org.mozilla.firefox//stable"
            "flathub:app/org.nomacs.ImageLounge//stable"
            "flathub:app/org.gnome.FileRoller//stable"
            "flathub:app/org.videolan.VLC//stable"
        ];

    };

    # GNOME apps depend on global config
    # https://nixos.wiki/wiki/GNOME#Running_GNOME_programs_outside_of_GNOME
    programs.dconf.enable = true;

    # Enable Hyprland. It has to be enabled on the system level too
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
    };

    # Tell Electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = 1;

    # Enable thunar here instead of using it with packages
    # see https://nixos.org/manual/nixos/stable/#sec-xfce-thunar-plugins
    programs.thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
            thunar-volman
            thunar-archive-plugin
        ];
    };

}
