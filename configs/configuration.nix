# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
    imports = [ 

        # Import home manager so we can manage home
        inputs.home-manager.nixosModules.home-manager 

        # Declarative flatpaks
        inputs.flatpaks.nixosModules.default

    ];

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;

    # networking.hostName = "nixos"; # Define your hostname. Moved to flake
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Los_Angeles";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
    };

    # Display Manager
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # Enable Hyprland
    programs.hyprland.enable = true;
    programs.hyprland.xwayland.enable = true;

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

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
  
    # Define people so Home Manager can find them
    users.users.justinhs = {
        isNormalUser = true;
        description = "Justin Schaaf";
        extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin. don't remove it like i did...
    };

    # Home Manager manages people
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        useGlobalPkgs = true;
        users.justinhs = import ../users/justinhs.nix;
    };

    # Nix settings
    nix.settings = {

        # Enable Flakes
        experimental-features = [ "nix-command" "flakes" ];

        # Enable binary caching so the flake stuff isn't constantly recompiled
        builders-use-substitutes = true;

        substituters = [
            "https://nix-community.cachix.org/"
            "https://hyprland.cachix.org"
            "https://anyrun.cachix.org"
        ];

        trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        ];

    }; 

    # List packages installed in system profile. To search, run:
    # $ nix search wget
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

        # System Utils/I want this to be OS installed
        pkgs.micro
        pkgs.fluent-icon-theme

        # Applications/To move to Flatpaks
        pkgs.kitty
        pkgs.blackbox-terminal
        
    ];

    # Flatpak config
    services.flatpak = {

        # Enable and add repo
        enable = true;
        remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
        # Branch is almost always "stable"
        packages = [
            "flathub:org.mozilla.firefox//stable"
        ];

    };

    # Fonts https://nixos.wiki/wiki/Fonts
    fonts = {

        # What fonts to install
        # Many here because a) i'm a font addict, and b) gimme some options like Windows
        packages = with pkgs; [
            b612
            barlow
            cascadia-code
            chonburi-font
            comic-neue
            corefonts
            crimson-pro
            dotcolon-fonts # includes alieron
            fira
            fraunces
            gelasio
            helvetica-neue-lt-std
            iwona
            jost
            joypixels
            junction-font
            lexend
            liberation_ttf
            manrope
            merriweather
            merriweather-sans
            monocraft
            mplus-outline-fonts.githubRelease
            nanum
            norwester-font
            #noto-fonts # I'm afraid of this adding all 200 fonts
            noto-fonts-emoji-blob-bin
            ostrich-sans
            overpass
            poly
            prociono
            raleway
            recursive
            rubik
            scientifica
            the-neue-black
            ubuntu_font_family
            unifont
            victor-mono
            vistafonts
            vollkorn
            work-sans
            zilla-slab
        ];

        # What fonts to use as default
        enableDefaultFonts = true;
        fontConfig.defaultFonts = {
            serif = [ "Blobmoji" "Gelasio" "Unifont" ];
            sansSerif = [ "Blobmoji" "Alieron" "Unifont" ]; # TODO Vercetti
            monospace = [ "Blobmoji" "Cascadia Code" "Unifont" ]; # TODO IBM Plex Mono
        };

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

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

}
