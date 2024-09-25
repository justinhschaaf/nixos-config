{ inputs, lib, config, pkgs, ... }:

{
  
    # Define people so Home Manager can find them
    users.users.justinhs = {
        isNormalUser = true;
        description = "Justin";
        initialPassword = "banana";
        extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin. don't remove it like i did...
    };

    # Home Manager manages people
    home-manager.users = lib.mkIf config.js.desktop.enable { justinhs = import ../hmusers/justinhs.nix; };

}

