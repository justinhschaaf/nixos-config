{ inputs, lib, config, pkgs, ... }: {

    # Blacklist unnecessary kernel modules
    # https://wiki.nixos.org/wiki/NixOS_Hardening#Module_blacklist
    boot.blacklistedKernelModules = [
        # Obscure network protocols
        "ax25"
        "dccp"
        "netrom"
        "rds"
        "rose"
        "sctp"
        "tipc"

        # Old or rare or insufficiently audited filesystems
        "adfs"
        "affs"
        "bfs"
        "befs"
        "cramfs"
        "efs"
        "erofs"
        "exofs"
        "freevxfs"
        "f2fs"
        "hfs"
        "hpfs"
        "jfs"
        "minix"
        "nilfs2"
        "omfs"
        "qnx4"
        "qnx6"
        "sysv"
        "ufs"
    ];

    # harden kernel params https://wiki.nixos.org/wiki/NixOS_Hardening#Kernel_parameters
    boot.kernelParams = [
        # Don't merge slabs
        "slab_nomerge"

        # Overwrite free'd pages
        "page_poison=1"

        # Enable page allocator randomization
        "page_alloc.shuffle=1"

        # Disable debugfs
        "debugfs=off"
    ];

    # Secure sysctl params https://wiki.nixos.org/wiki/NixOS_Hardening#Sysctl_parameters

    # Hide kptrs even for processes with CAP_SYSLOG
    boot.kernel.sysctl."kernel.kptr_restrict" = "2";

    # Disable bpf() JIT (to eliminate spray attacks)
    boot.kernel.sysctl."net.core.bpf_jit_enable" = false;

    # Disable ftrace debugging
    boot.kernel.sysctl."kernel.ftrace_enabled" = false;

    # Disable the magic SysRq key
    # https://arciveo.com/en/blog/lynis-hardening-index#:~:text=Kernel%20parameters%20%28KRNL%2D6000%29%2E
    boot.kernel.sysctl."kernel.sysrq" = "0";

    # Enable strict reverse path filtering (that is, do not attempt to route
    # packets that "obviously" do not belong to the iface's network; dropped
    # packets are logged as martians).
    boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = true;
    boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = "1";
    boot.kernel.sysctl."net.ipv4.conf.default.log_martians" = true;
    boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = "1";

    # Ignore broadcast ICMP (mitigate SMURF)
    boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = true;

    # Ignore incoming ICMP redirects (note: default is needed to ensure that the
    # setting is applied to interfaces added after the sysctls are set)
    boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = false;
    boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = false;
    boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = false;

    # Ignore outgoing ICMP redirects (this is ipv4 only)
    boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = false;

    # Enable nodev and nosuid on most file systems
    # Not enabling noexec on most since I'm a developer, I need to do dev stuff!
    # noexec was enabled for /root, /home, /srv, and /var/log but Nix complained those aren't actual mounts
    # disabling /boot options because Nix complains about it duuring install
    fileSystems."/".options = [ "nodev" "nosuid" ];

    # Prevent logrotate from checking the config at buildtime, resolves an issue caused by the hardened kernel
    # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000/28501
    services.logrotate.checkConfig = false;

    # Cleanup tmp upon boot, why tf is this documentation shit
    # https://github.com/NixOS/nixpkgs/issues/96753
    # https://man.archlinux.org/man/tmpfiles.d.5
    # https://www.baeldung.com/linux/systemd-tmpfiles-configure-temporary-files
    systemd.tmpfiles.rules = [ "D! %T 1777 root root" ];

    # lock kernel modules after the system is initialized
    security.lockKernelModules = true;

    # prevent replacing the currently running kernel
    security.protectKernelImage = true;

    # Enable AppArmor
    security.apparmor.enable = true;
    security.apparmor.killUnconfinedConfinables = true;

    # Replace sudo with sudo-rs and only let wheel use it
    security.sudo.enable = false;
    security.sudo-rs.enable = true;
    security.sudo-rs.execWheelOnly = true;

    # Prevent unpriviledged users from interacting with nix cmd
    # TODO configure comin to have its own account instead of using root
    nix.settings.allowed-users = [ "@wheel" ];

    # Prevent unpriviledged users from modifying cups config
    # https://discourse.nixos.org/t/group-to-allow-managing-cups-printers/48359
    services.printing.extraFilesConf = lib.mkIf config.services.printing.enable ''
        SystemGroup root wheel
    '';

}
