{ inputs, lib, config, pkgs, ... }: {

    options.js.network.nm.enable = lib.mkEnableOption "NetworkManager + IWD, which should be used on newer devices." // {
        default = true;
    };

    config = {

        # config for wpa_supplicant on legacy systems, usuable with wpa_gui or wpa_cli
        # networkmanager is easier to use and more private, only resort to this if you have to!!!
        networking.wireless = lib.mkIf (!config.js.network.nm.enable) {
            enable = true;
            userControlled.enable = true;
        };

        # this is used for all other systems
        networking.networkmanager = lib.mkIf config.js.network.nm.enable {
            # Enable networking, usuable with nmtui
            enable = true;

            # Replace wpa_supplicant with IWD, if enabled
            # https://kokada.dev/blog/an-unordered-list-of-hidden-gems-inside-nixos/
            # https://wmbuck.net/blog/?p=1313
            wifi.backend = "iwd";

            # Also enable privacy tweaks to hide MAC address https://privsec.dev/posts/linux/desktop-linux-hardening/#privacy-tweaks
            wifi.macAddress = "random";
            wifi.scanRandMacAddress = true;
            ethernet.macAddress = "random";
        };

        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        networking.useDHCP = lib.mkDefault true;

        # use nftables instead of iptables
        # note in case docker ever gets enabled: this fucks with docker
        # podman is fine
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

    };

}

