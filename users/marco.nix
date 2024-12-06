{ inputs, lib, config, pkgs, ... }:

{

    users.users.marco = {
        isNormalUser = true;
        description = "Marco Polo";
        password = "pasta"; # we are intentionally using a public password, this is the generic user
    };

    home-manager.users = lib.mkIf config.js.desktop.enable { marco = import ../hmusers/marco.nix; };

}

