{ inputs, config, pkgs, ... }:

{
  
    # Define people so Home Manager can find them
    users.users.justinhs = {
        isNormalUser = true;
        description = "Justin";
        extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin. don't remove it like i did...
    };

    # Home Manager manages people
    home-manager.users.justinhs = import ../hmusers/justinhs.nix;

}
