{ inputs, config, pkgs, ... }:

{

    imports = [ 

        # Declarative flatpaks
        inputs.flatpaks.nixosModules.default

        # Fonts
        ./fonts.nix

    ];

    # Display Manager
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # XDG Desktop Portal
    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

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

    environment.systemPackages = [
        
        # Hyprland Stuff/Basic System Functionality
        pkgs.eww
        pkgs.libnotify
        pkgs.mako
        pkgs.polkit_gnome
        pkgs.swww
        pkgs.udiskie
        inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins
        # https://github.com/ArtsyMacaw/wlogout
        # https://github.com/ErikReider/SwayOSD

        # System Utils
        pkgs.fluent-icon-theme

        # Applications
        pkgs.blackbox-terminal
        pkgs.gnome.gnome-system-monitor
        
    ];

    # Flatpak config
    services.flatpak = {

        # Enable and add repo
        enable = true;
        remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        packages = [
            "flathub:com.github.tchx84.Flatseal//stable"
            "flathub:org.mozilla.firefox//stable"
            "flathub:org.nomacs.ImageLounge//stable"
            "flathub:org.gnome.FileRoller//stable"
        ];

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
