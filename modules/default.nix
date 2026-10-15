{ inputs, lib, config, pkgs, ... }: {

    imports = [

        # Use Determinate Nix
        inputs.determinate.nixosModules.default

        # Everything is imported here
        ./desktop
        ./hardware
        ./programs
        ./server
        ./utils

        ./network.nix
        ./security.nix

    ];

    # Limine bootloader. will be the default when https://github.com/NixOS/nixpkgs/issues/443031 is fixed
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.limine = {
        enable = lib.mkDefault false;
        style.wallpapers = lib.mkForce [ ];
        style.graphicalTerminal.palette = "1d1f21;cc6666;b5bd68;de935f;81a2be;b294bb;8abeb7;c5c8c6";

        # add memtest86
        extraEntries = ''
        /memtest86plus
          protocol: chainload
          path: boot():///efi/memtest86plus/mt86plus.efi
        '';
        additionalFiles = { "efi/memtest86plus/mt86plus.efi" = pkgs.memtest86plus.efi; };
    };

    # Grub bootloader.
    boot.loader.grub = {

        enable = lib.mkDefault true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;

        # set maximum number of generations in the bootloader to 8.
        # if this is not set, nixos will keep too many prior kernels in the boot
        # partition, then fail to rebuild due to lack of space deleting them
        # manually then rebuilding used to work, but no longer does.
        # boot partition running out of space has been a problem since 2017
        # https://github.com/NixOS/nixpkgs/issues/23926
        # default is 100 btw, what the actual fuck
        configurationLimit = 8;

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
            menuentry "Memtest86+" {
                linux @bootRoot@/memtest.bin
            }
        '';

        # add memtest86
        extraFiles."memtest.bin" = pkgs.memtest86plus.efi;

        # Disable the NixOS theme
        theme = null;
        splashImage = null;

    };

    # Hardened kernel linuxPackages_hardened was removed, see https://github.com/NixOS/nixpkgs/pull/502342
    # Use Zen kernel instead https://github.com/zen-kernel/zen-kernel/wiki/Detailed-Feature-List
    boot.kernelPackages = pkgs.linuxPackages_zen;

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

    # Automatically optimise the store
    nix.optimise.automatic = true;

    # most of these are declared in the flake why tf do i have to do it again
    nix.settings = {

        # Allow flakes and nix-command systemwide
        experimental-features = [ "nix-command" "flakes" ];
        accept-flake-config = true;

        # Hard links copies of identitical files in the store to each other
        auto-optimise-store = true;

        # Enable binary caching so the flake stuff isn't constantly recompiled
        builders-use-substitutes = true;

        # increase download buffer size to stop updates stalling on server
        download-buffer-size = 2147483648;

        substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org/"
            "https://hyprland.cachix.org"
        ];

        trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];

    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Configure /etc/issue, used by getty and ssh
    # https://gist.github.com/hvmonteiro/7f897cd8ae3993195855040056f87dc6
    environment.etc.issue.source = pkgs.writeText "issue" ''

        ┌─ ${config.system.nixos.distroName} ${config.system.nixos.label} (${pkgs.stdenv.hostPlatform.system}) ─ \l ───────────────────────────────────────────────────────┐
        │                                                                                                            │
        │                                                 \e[1;97;41m WARNING! \e[0m                                                 │
        │                                                                                                            │
        │  This system is restricted to authorized users only. All activities on this system may be monitored.       │
        │  Unauthorized access will be fully investigated and reported to the appropriate law enforcement agencies.  │
        │                                                                                                            │
        └────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

    '';

    # Add TUI programs and enable automatic updates by default
    js.programs.tui.enable = lib.mkDefault true;
    js.update.enable = lib.mkDefault true;

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

