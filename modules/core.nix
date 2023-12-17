{ inputs, config, pkgs, ... }:

{

    # Bootloader. If you wanna use systemd, it's boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {

        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;

        # CA Keys Secure Boot support https://wiki.archlinux.org/title/GRUB#CA_Keys
        # Bootloader still doesn't like it, likely need UKI support before it works https://wiki.archlinux.org/title/Unified_kernel_image
        #extraGrubInstallArgs = [ "--bootloader-id=GRUB" "--modules=tpm" "--disable-shim-lock" ];

        # UEFI Bootloader entry, based on auto-generated Fedora config
        # and https://unix.stackexchange.com/questions/528454/how-do-i-add-firmware-setup-option-to-grub#532183
        extraEntries = ''
            if [ "$grub_platform" = "efi" ]; then
                menuentry 'UEFI Firmware Settings' $menuentry_id_option 'uefi-firmware' {
                    fwsetup
                }
            fi
        '';

        # Disable the NixOS theme
        theme = null;
        splashImage = null;

    };

    # Enable networking, usuable with nmtui
    networking.networkmanager.enable = true;
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

    # Automatically run updates using fcron instead of system.autoUpgrade
    # https://man.archlinux.org/man/fcrontab.5.en
    # TODO make this fetch the latest config from GitHub and setup GitHub CI to update the flake.lock
    #services.fcron = {
    #    enable = true;
    #    systab = ''
    #        & 0 12 * * * sudo nixos-rebuild boot --upgrade
    #        '';
    #};

    # Allow flakes and nix-command systemwide
    # this is declared in the flake why tf do i have to do it again
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        hyfetch
        micro
    ];

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
