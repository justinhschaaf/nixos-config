{ inputs, lib, config, pkgs, ... }:

{

    users.users.sysadmin = {
        isNormalUser = true;
        description = "System Administrator";
        initialPassword = "apricot";
        extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin. don't remove it like i did...
    };

    home-manager.users = lib.mkIf config.js.desktop.enable { sysadmin = import ../hmusers/sysadmin.nix; };

}
