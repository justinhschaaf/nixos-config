{ inputs, config, pkgs, ... }:

{

    imports = [ 
        # Import home manager so we can manage home
        inputs.home-manager.nixosModules.home-manager 
    ];
  
    # Define people so Home Manager can find them
    users.users.justinhs = {
        isNormalUser = true;
        description = "Justin Schaaf";
        extraGroups = [ "networkmanager" "wheel" ]; # wheel = admin. don't remove it like i did...
    };

    # Home Manager manages people
    home-manager = {
        extraSpecialArgs = { inherit inputs; };
        useGlobalPkgs = true;
        users.justinhs = import ../hmusers/justinhs.nix;
    };

}
