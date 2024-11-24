{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.desktop.input.jp = lib.mkEnableOption "Japanese input via fcitx5 and mozc";
    };

    # Enable Japanese keyboard input. Switch between Latin and JP with Alt+Space
    config = lib.mkIf config.js.desktop.input.jp {

        i18n.inputMethod.enable = true;
        i18n.inputMethod.type = "fcitx5";
        i18n.inputMethod.fcitx5 = {
            waylandFrontend = true;
            addons = with pkgs; [
                fcitx5-mozc
                fcitx5-nord
            ];
            settings.inputMethod = {
                "Groups/0" = {
                    "Name" = "Default";
                    "Default Layout" = "us";
                    "DefaultIM" = "mozc";
                };
                "Groups/0/Items/0"."Name" = "keyboard-us";
                "Groups/0/Items/1"."Name" = "mozc";
                "GroupOrder"."0" = "Default";
            };
            settings.globalOptions = {
                "Hotkey/TriggerKeys"."0" = "Alt+space";
            };
        };

        environment.sessionVariables.GLFW_IM_MODULE = "ibus";

    };

}

