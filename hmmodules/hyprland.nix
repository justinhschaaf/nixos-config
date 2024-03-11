#
# Hyprland and helper applications
#

{ inputs, osConfig, config, pkgs, ... }:

{
    # Import default configs so flakes know how to behave by default
    imports = [ 
        inputs.anyrun.homeManagerModules.default
    ];

    # hyprland config imported from file
    wayland.windowManager.hyprland = {
        
        enable = true;
        xwayland.enable = true;

        settings = {

            # Please note not all available settings / options are set here.
            # For a full list, see the wiki

            # See https://wiki.hyprland.org/Configuring/Monitors/
            # Wdisplays exists and is installed, but config doesn't save between restarts
            monitor = if "${osConfig.system.name}" == "justinhs-go" 
                then ",preferred,auto,1.5" 
                else ",preferred,auto,auto";

            # This is necessary to force Hyprland to stfu about using 1.5 scale
            # IT WAS WORKING FINE BEFORE V34
            # https://github.com/hyprwm/Hyprland/issues/4225
            debug.disable_scale_checks = 1;

            # Idle lock https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
            "$lock" = "grim /tmp/lock.png && gm mogrify -blur 20x20 -fill black -colorize 80 file /tmp/lock.png && swaylock -fklr --image /tmp/lock.png --separator-color 00000000";

            # Screenshot editor
            "$satty" = "satty --filename - --fullscreen --copy-command 'wl-copy' --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H%M%S').png";

            # Startup apps
            # launch location for gnome polkit: https://nixos.wiki/wiki/Polkit
            exec-once = [

                "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
                "udiskie -A" # -A = no automount
                "mako"
                "swww init"

                # System sleep
                "sway-audio-idle-inhibit"
                "swayidle -w timeout 300 '$lock' timeout 300 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep '$lock'"
            
            ];

            # Get KDE file picker to show up properly
            # At least I can actually paste in a file path now
            # https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
            windowrulev2 = [
                "float,class:^(org.freedesktop.impl.portal.desktop.kde)$"
                "center,class:^(org.freedesktop.impl.portal.desktop.kde)$"
                "maximize,class:^(org.freedesktop.impl.portal.desktop.kde)$"
            ];

            # Some default env vars.
            env = "XCURSOR_SIZE,24";

            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            gestures.workspace_swipe = false;
            misc.force_default_wallpaper = 0; # No more anime girl jumpscares

            input = {
                kb_layout = "us";
                follow_mouse = 1;
                numlock_by_default = true;
                touchpad.natural_scroll = false;
                sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
            };

            general = {

                gaps_in = 4;
                gaps_out = 12;
                border_size = 2;
                layout = "dwindle";

                "col.active_border" = "rgba(ffffffff)";
                "col.inactive_border" = "rgba(595959aa)";

            };

            decoration = {

                rounding = 0;

                drop_shadow = true;
                shadow_range = 4;
                shadow_render_power = 3;
                "col.shadow" = "rgba(1a1a1aee)";

                blur = {
                    enabled = true;
                    size = 10;
                    passes = 2;
                    new_optimizations = true;
                };
                
            };

            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
            animations = {
                enabled = true;
                bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
                animation = [
                    "windows, 1, 7, myBezier"
                    "windowsOut, 1, 7, default, popin 80%"
                    "border, 1, 10, default"
                    "borderangle, 1, 8, default"
                    "fade, 1, 7, default"
                    "workspaces, 1, 6, default"
                ];
            };

            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            dwindle = {
                pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
                preserve_split = true; # you probably want this
            };

            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            master.new_is_master = true;

            # See https://wiki.hyprland.org/Configuring/Keywords/ for more
            "$mainMod" = "SUPER";

            bind = [

                # Application keybinds, see https://wiki.hyprland.org/Configuring/Binds/ for more
                "$mainMod, space, exec, anyrun"
                "$mainMod, T, exec, kitty"
                "$mainMod, E, exec, thunar"
                "$mainMod, R, exec, gnome-system-monitor"
                "$mainMod, period, exec, flatpak run dev.krtirtho.Flemozi" # same as windows
                "$mainMod SHIFT, C, exec, notify-send -a 'hyprpicker' 'Color: $(hyprpicker -anr)' 'The selected color has been copied to your clipboard.'" # same as powertoys

                # System keybinds
                "$mainMod, L, exec, $lock"

                # Screenshot
                ", Print, exec, grimblast --freeze save area - | $satty"
                "CTRL, Print, exec, grimblast --freeze save active - | $satty"
                "ALT, Print, exec, grimblast --freeze save output - | $satty"

                # Brightness and volume https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
                ", xf86monbrightnessup, exec, brightnessctl set 5%+"
                ", xf86monbrightnessdown, exec, brightnessctl set 5%-"
                ", xf86audioraisevolume, exec, wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+"
                ", xf86audiolowervolume, exec, wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%-"
                ", xf86audiomute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"

                # Application interactions
                "$mainMod, Q, killactive,"
                "$mainMod, V, togglefloating," 
                "$mainMod, P, pseudo," # dwindle
                "$mainMod, J, togglesplit," # dwindle

                # Move focus with mainMod + arrow keys
                "$mainMod, left, movefocus, l"
                "$mainMod, right, movefocus, r"
                "$mainMod, up, movefocus, u"
                "$mainMod, down, movefocus, d"

                # Switch workspaces with mainMod + [0-9]
                "$mainMod, 1, workspace, 1"
                "$mainMod, 2, workspace, 2"
                "$mainMod, 3, workspace, 3"
                "$mainMod, 4, workspace, 4"
                "$mainMod, 5, workspace, 5"
                "$mainMod, 6, workspace, 6"
                "$mainMod, 7, workspace, 7"
                "$mainMod, 8, workspace, 8"
                "$mainMod, 9, workspace, 9"
                "$mainMod, 0, workspace, 10"

                # Move active window to a workspace with mainMod + SHIFT + [0-9]
                "$mainMod SHIFT, 1, movetoworkspace, 1"
                "$mainMod SHIFT, 2, movetoworkspace, 2"
                "$mainMod SHIFT, 3, movetoworkspace, 3"
                "$mainMod SHIFT, 4, movetoworkspace, 4"
                "$mainMod SHIFT, 5, movetoworkspace, 5"
                "$mainMod SHIFT, 6, movetoworkspace, 6"
                "$mainMod SHIFT, 7, movetoworkspace, 7"
                "$mainMod SHIFT, 8, movetoworkspace, 8"
                "$mainMod SHIFT, 9, movetoworkspace, 9"
                "$mainMod SHIFT, 0, movetoworkspace, 10"

                # Scroll through existing workspaces with mainMod + scroll
                "$mainMod, mouse_down, workspace, e+1"
                "$mainMod, mouse_up, workspace, e-1"

            ];

            bindm = [
                # Move/resize windows with mainMod + LMB/RMB and dragging
                "$mainMod, mouse:272, movewindow"
                "$mainMod, mouse:273, resizewindow"
            ];

        };

    };

    # enable eww and link config location
    programs.eww = {
        enable = true;
        configDir = ../dotfiles/eww;
    };

    programs.anyrun = {

        enable = true;

        config = {
            plugins = [ # Everything except randr, stdin, and dictionary
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libapplications.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libkidex.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/librink.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libshell.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libsymbols.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libtranslate.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libwebsearch.so"
            ];
        };

        # Websearch plugin
        extraConfigFiles."websearch.ron".text = ''
            Config(
                prefix: "?",
                engines: [DuckDuckGo] 
            )
        '';

    };

    # TODO https://mipmip.github.io/home-manager-option-search/?query=mako

}


