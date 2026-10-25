{ inputs, lib, config, pkgs, ... }: {

    imports = [
        ./data
        ./monitoring
        ./services
    ];

    options.js.server = {
        enable = lib.mkEnableOption "server defaults";
        openFirewall = lib.mkOption { default = false; };
        ssh.enable = lib.mkEnableOption "SSH";
        ssh.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
        tarpits.enable = lib.mkEnableOption "tarpits for malicious actors";
        tarpits.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    # Enable SSH
    config.services.openssh = lib.mkIf config.js.server.ssh.enable {
        enable = true;
        ports = [ 2720 ];
        openFirewall = config.js.server.ssh.openFirewall;
        settings = {
            Banner = "/etc/issue.net";

            # Hardening
            # https://arciveo.com/en/blog/lynis-hardening-index#:~:text=SSH%20%28SSH%2D7408%29%2E
            PermitRootLogin = "no";
            #PasswordAuthentication = false; # TODO configure public key authentication
            MaxAuthTries = 3;
            MaxSessions = 2;
            X11Forwarding = false;
            AllowTcpForwarding = "no";
            ClientAliveInterval = 300;
            ClientAliveCountMax = 2;
            LogLevel = "VERBOSE";
            TCPKeepAlive = false;
        };
    };

    # Tarpits to fuck with attackers
    config.services.endlessh-go = lib.mkIf config.js.server.tarpits.enable {
        enable = true;
        port = 22;
        openFirewall = config.js.server.tarpits.openFirewall;
    };

    config.services.avahi = lib.mkIf config.js.server.enable {
        settings.publish.disable-publishing = false;
        settings.publish.publish-domain = true;
    };

}

