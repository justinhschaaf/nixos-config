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

    # Display Manager
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.xserver.libinput.enable = true;

    # XDG Desktop Portal
    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
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
        pkgs.eww-wayland
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
        pkgs.satty
        pkgs.slurp

        # Sleep
        pkgs.sway-audio-idle-inhibit
        pkgs.swayidle
        pkgs.swaylock

        # File thumbnails
        pkgs.f3d
        pkgs.ffmpegthumbnailer
        pkgs.libgsf
        pkgs.poppler
        pkgs.webp-pixbuf-loader

        # Applications
        pkgs.blackbox-terminal
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

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        packages = [
            "flathub:app/com.gitlab.davem.ClamTk//stable"
            "flathub:app/com.github.tchx84.Flatseal//stable"
            "flathub:app/org.mozilla.firefox//stable"
            "flathub:app/org.nomacs.ImageLounge//stable"
            "flathub:app/org.gnome.FileRoller//stable"
            "flathub:app/org.videolan.VLC//stable"
        ];

    };

    # Enable Hyprland. It has to be enabled on the system level too
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
    };

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
