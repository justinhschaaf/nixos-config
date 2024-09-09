{ inputs, lib, config, pkgs, ... }: {

    imports = [ 

        # Everything is imported here
        ./desktop
        ./hardware
        ./programs
        ./server
        ./autoupdate.nix
        ./sops.nix

    ];

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

    # Hardened Linux kernel, this shouldn't work linuxPackages_hardened isn't a thing in nixpkgs
    # https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=linuxPackages_hardened
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix#L18
    boot.kernelPackages = pkgs.linuxPackages_hardened;

    # Enable nodev and nosuid on most file systems
    # Not enabling noexec on most since I'm a developer, I need to do dev stuff!
    # noexec was enabled for /root, /home, /srv, and /var/log but Nix complained those aren't actual mounts
    # disabling /boot options because Nix complains about it duuring install
    fileSystems."/".options = [ "nodev" "nosuid" ];

    # Enable networking, usuable with nmtui
    # Also enable privacy tweaks to hide MAC address https://privsec.dev/posts/linux/desktop-linux-hardening/#privacy-tweaks
    networking.networkmanager = {
        enable = true;
        ethernet.macAddress = "random";
        wifi.macAddress = "random";
        wifi.scanRandMacAddress = true;
    };

    # use nftables instead of iptables
    # note in case docker ever gets enabled: this fucks with docker
    networking.nftables.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Configure DNSSEC with systemd-resolved to use Cloudflare and Quad9 https://wiki.nixos.org/wiki/Systemd-resolved
    networking.nameservers = [ "1.1.1.1" "1.0.0.1" "9.9.9.9" "149.112.112.112" ];

    services.resolved = {
        enable = true;
        dnssec = "true"; # yes, these are strings
        dnsovertls = "true";
        domains = [ "~." ];
        fallbackDns = [ "1.1.1.1" "1.0.0.1" "9.9.9.9" "149.112.112.112" ];
    };

    # Enable Avahi for zeroconf networking, firewall is opened for it by default
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;

    # Setup Chrony with NTS for time server security
    # https://privsec.dev/posts/linux/desktop-linux-hardening/#time-synchronization
    services.chrony = {

        enable = true;
        enableNTS = true;
        extraFlags = [ "-F 1" ];

        # https://github.com/jauderho/nts-servers
        # https://netfuture.ch/public-nts-server-list/
        servers = [
            "time.cloudflare.com"
            "oregon.time.system76.com"
            "virginia.time.system76.com"
            "time.cifelli.xyz"
            "time.txryan.com"
            "ntppool1.time.nl"
            "ntppool2.time.nl"
            "nts.netnod.se"
            "nts.ntstime.de"
            "time.bolha.one"
        ];

        extraConfig = ''
            minsources 4
        '';

    };

    # Prevent logrotate from checking the config at buildtime, resolves an issue caused by the hardened kernel
    # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000/28501
    services.logrotate.checkConfig = false;

    # Cleanup tmp upon boot, why tf is this documentation shit
    # https://github.com/NixOS/nixpkgs/issues/96753
    # https://man.archlinux.org/man/tmpfiles.d.5
    # https://www.baeldung.com/linux/systemd-tmpfiles-configure-temporary-files
    systemd.tmpfiles.rules = [ "D! %T 1777 root root" ];

    # Replace sudo with sudo-rs and only let wheel use it
    security.sudo.enable = false;
    security.sudo-rs.enable = true;
    security.sudo-rs.execWheelOnly = true;

    # Set your time zone. This is set to default since Authentik overrides it.
    time.timeZone = lib.mkDefault "America/Los_Angeles";

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

    # Allow flakes and nix-command systemwide
    # this is declared in the flake why tf do i have to do it again
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Only allow sudoers to use nix
    nix.settings.allowed-users = [ "@wheel" ];

    # Automatically optimise the store
    nix.optimise.automatic = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Add TUI programs and enable firmware updates by default
    js.programs.tui.enable = lib.mkDefault true;
    js.autoUpdate.firmware.enable = lib.mkDefault true;

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
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

}

