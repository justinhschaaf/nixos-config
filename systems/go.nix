{ inputs, lib, config, pkgs, ... }: {

    # Autoupdate. Disabled while this is my primary testing device
    #js.autoUpdate.enable = true;

    # Enable Hyprland and JP keyboard
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;
    js.desktop.input.jp = true;

    # Enable Thunar and dev tools
    js.programs.dev.enable = true;
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "justinhs-go";

    # Enable fingerprint scanner https://community.frame.work/t/framework-nixos-linux-users-self-help-firmware-fingerprint-discussion/46565/22
    services.fprintd.enable = true;

    # Default Unix rules are mostly set good, just check fingerprint after and allow null password
    # https://github.com/NixOS/nixpkgs/pull/255547
    # https://wiki.archlinux.org/title/Fprint#Configuration
    # https://github.com/NixOS/nixpkgs/blob/5c24cf2f0a12ad855f444c30b2421d044120c66f/nixos/modules/security/pam.nix#L647
    security.pam.services = let
        serviceCfg = service: {
            allowNullPassword = true;
            rules.auth.fprintd.order = config.security.pam.services.${service}.rules.auth.unix.order + 10;
        };
    in lib.flip lib.genAttrs serviceCfg [
        "greetd"
        "swaylock"
    ];

}

