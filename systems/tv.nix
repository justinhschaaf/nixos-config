{ inputs, config, pkgs, ... }: {

    # Enable autoupdate
    js.autoUpdate.enable = true;
    js.autoUpdate.sendNotif = true;

    # Enable Hyprland
    js.desktop.enable = true;
    js.desktop.hyprland.enable = true;

    # Enable Thunar
    js.programs.thunar.enable = true;

    # Set system name
    networking.hostName = "lasagna";

}
