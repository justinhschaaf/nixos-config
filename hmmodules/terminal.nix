#
# Fish, Kitty, and Micro
#

{ inputs, config, pkgs, ... }:

{

    # Terminal toys
    home.packages = with pkgs; [ 
        cmatrix
        dotacat
        jp2a
        pipes-rs
    ];

    # Disable the greeting https://fishshell.com/docs/current/cmds/fish_greeting.html
    programs.fish.enable = true;
    programs.fish.functions.fish_greeting = "";

    # Kitty conig. Note that it doesn't like floats
    programs.kitty = {

        enable = true;
        shellIntegration.enableFishIntegration = true;

        settings = {

            # Window options
            window_padding_width = 10;
            background_opacity = "0.8";
            confirm_os_window_close = 0;

            # Cursor and font options
            font_size = 12;
            cursor_shape = "underline";
            cursor_blink_interval = "0.7";
            tab_bar_style = "slant";

            # Behavior
            shell_integration = "no-cursor";
            paste_actions = "quote-urls-at-prompt,replace-newline,confirm-if-large";
            strip_trailing_spaces = "smart";

            # Notifications
            enable_audio_bell = "no";
            notify_on_cmd_finish = "invisible notify";

            # Tomorrow Night theme from Blackbox Terminal
            # see https://gitlab.gnome.org/raggesilver/blackbox/-/blob/55f34e75d16c51a12b2522bc30e1f53a417ac973/data/schemes/tommorow-night.json
            foreground = "#c5c8c6";
            background = "#1d1f21";
            color0 = "#000000";
            color1 = "#cc6666";
            color2 = "#b5bd68";
            color3 = "#f0c674";
            color4 = "#81a2be";
            color5 = "#b294bb";
            color6 = "#8abeb7";
            color7 = "#ffffff";
            color8 = "#000000";
            color9 = "#cc6666";
            color10 = "#b5bd68";
            color11 = "#f0c674";
            color12 = "#81a2be";
            color13 = "#b294bb";
            color14 = "#8abeb7";
            color15 = "#ffffff";
            
        };

    };

    # micro editor config https://github.com/zyedidia/micro/blob/master/runtime/help/options.md
    programs.micro.enable = true;
    programs.micro.settings = {
        rmtrailingws = true;
        saveundo = true;
        tabstospaces = true;
    };

}
