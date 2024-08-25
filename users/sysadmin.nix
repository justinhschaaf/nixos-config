{ inputs, lib, config, pkgs, ... }:

{

    users.users.sysadmin = {
        isNormalUser = true;
        description = "System Administrator";
        initialPassword = "penis";
        extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin. don't remove it like i did...
    };

}
