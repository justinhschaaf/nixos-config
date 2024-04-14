{ inputs, config, pkgs, ... }: {

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

}
