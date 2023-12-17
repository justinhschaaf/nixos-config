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
            # Custom config superseded by wdisplays, hopefully
            #monitor = if "${osConfig.system.name}" == "justinhs-go" 
            #    then ",preferred,auto,1.5" 
            #    else ",preferred,auto,auto";
            monitor = ",preferred,auto,auto";

            # Idle lock https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
            "$lock" = "swaylock --daemonize";

            # Startup apps
            # & after each applications means launch in background
            # e.g. exec-once = waybar & hyprpaper & firefox
            # launch location for gnome polkit: https://nixos.wiki/wiki/Polkit
            exec-once = ''
            mako & ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 & udiskie & sway-audio-idle-inhibit &
            swayidle -w timeout 300 '$lock' timeout 300 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep '$lock' &
            '';

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

                gaps_in = 5;
                gaps_out = 20;
                border_size = 2;
                layout = "dwindle";

                "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
                "col.inactive_border" = "rgba(595959aa)";

            };

            decoration = {

                rounding = 10;

                drop_shadow = true;
                shadow_range = 4;
                shadow_render_power = 3;
                "col.shadow" = "rgba(1a1a1aee)";

                blur = {
                    enabled = true;
                    size = 3;
                    passes = 1;
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
                "$mainMod, T, exec, blackbox"
                "$mainMod, E, exec, thunar"
                "$mainMod, R, exec, gnome-system-monitor"
                "$mainMod, period, exec, flatpak run dev.krtirtho.Flemozi" # same as windows
                "$mainMod SHIFT, C, exec, flatpak run com.github.finefindus.eyedropper" # same as powertoys

                # System keybinds
                "$mainMod, L, exec, $lock"

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

}


