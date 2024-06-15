{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.hardware.fingerprint.enable = lib.mkEnableOption "fingerprint reader support";
    };

    config = lib.mkIf config.js.hardware.fingerprint.enable {

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

    };

}

