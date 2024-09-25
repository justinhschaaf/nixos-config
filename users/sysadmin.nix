{ inputs, lib, config, pkgs, ... }:

{

    users.users.sysadmin = {
        isNormalUser = true;
        description = "System Administrator";
        initialPassword = "apricot";
        extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin. don't remove it like i did...
    };

}
