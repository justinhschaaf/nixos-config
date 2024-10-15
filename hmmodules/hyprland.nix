{ inputs, lib, osConfig, config, pkgs, ... }: {

    options = {
        js.hm.hyprland.enable = lib.mkOption { default = osConfig.js.desktop.hyprland.enable; };
    };

    # Hyprland and helper applications
    config = let
        lockcmd = "grim /tmp/lock.png && gm mogrify -blur 20x10 -fill black -colorize 20 /tmp/lock.png && swaylock -fklr --image /tmp/lock.png --separator-color 00000000";
    in lib.mkIf config.js.hm.hyprland.enable {

        # hyprland config imported from file
        wayland.windowManager.hyprland = {

            enable = true;
            xwayland.enable = true;

            settings = {

                # Please note not all available settings / options are set here.
                # For a full list, see the wiki

                # See https://wiki.hyprland.org/Configuring/Monitors/
                # Wdisplays exists and is installed, but config doesn't save between restarts
                monitor = if "${osConfig.system.name}" == "farfalle"
                    then ",preferred,auto,1.5"
                    else if "${osConfig.system.name}" == "bucatini"
                    then [
                        "DP-1,preferred,1920x0,1"
                        "DP-2,preferred,0x0,1"
                    ] else",preferred,auto,auto";

                # This is necessary to force Hyprland to stfu about using 1.5 scale
                # IT WAS WORKING FINE BEFORE V34
                # https://github.com/hyprwm/Hyprland/issues/4225
                debug.disable_scale_checks = 1;

                # Lock command https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
                "$lock" = lockcmd;

                # Screenshot editor
                "$satty" = "satty --filename - --fullscreen --copy-command 'wl-copy' --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H%M%S').png";

                # Startup apps
                # launch location for gnome polkit: https://wiki.nixos.org/wiki/Polkit
                exec-once = [

                    "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
                    "udiskie -A -f thunar" # -A = no automount
                    "mako"
                    "waybar"
                    "swww-daemon"
                    "fcitx5 -d" # -d = daemon

                    # System sleep
                    "hypridle"

                ];

                # Get KDE file picker to show up properly
                # At least I can actually paste in a file path now
                # https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
                windowrulev2 = [
                    "float,class:^(org.freedesktop.impl.portal.desktop.kde)$"
                    "center,class:^(org.freedesktop.impl.portal.desktop.kde)$"
                    "maximize,class:^(org.freedesktop.impl.portal.desktop.kde)$"
                ];

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
                    gaps_out = "6, 12, 12, 12";
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

                # Nvidia performance
                # https://wiki.hyprland.org/Nvidia/
                cursor.no_hardware_cursors = true;

                # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
                dwindle = {
                    pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
                    preserve_split = true; # you probably want this
                };

                # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
                # https://github.com/hyprwm/Hyprland/pull/6479
                master.new_status = "master";

                # See https://wiki.hyprland.org/Configuring/Keywords/ for more
                "$mainMod" = "SUPER";

                bind = [

                    # Application keybinds, see https://wiki.hyprland.org/Configuring/Binds/ for more
                    "$mainMod, space, exec, anyrun"
                    "$mainMod, T, exec, kitty"
                    "$mainMod, E, exec, thunar"
                    "$mainMod, R, exec, resources"
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

        # configure hypridle
        # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
        # https://home-manager-options.extranix.com/?query=hypridle&release=release-24.05
        services.hypridle.enable = true;
        services.hypridle.settings = {
            general = {
                lock_cmd = "pidof swaylock || ${lockcmd}";
                before_sleep_cmd = "loginctl lock-session";
            };
            listener = [{
                timeout = 300;
                on-timeout = "loginctl lock-session";
            } {
                timeout = 330;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
            }];
        };

        # setup waybar
        programs.waybar.enable = true;
        programs.waybar.settings.taskbar = {

            # where do we put it
            layer = "top";
            height = 32;
            spacing = 0;

            # what's in the bar?
            # TODO add system resources/utilization group for easy monitoring?
            modules-left = [ "hyprland/workspaces" ];
            modules-center = [ "clock" ];
            modules-right = [
                "privacy"
                "battery"
                "group/controls"
                "group/power"
            ];

            # hyprland workspace switcher
            "hyprland/workspaces" = {
                sort-by = "number";
                persistent-workspaces."*" = 10;
                format = "{icon}";
                format-icons = {
                    empty = "";
                    default = "";
                };
            };

            # date/time (centered). hover = calendar, scroll = change time zone
            clock = {
                interval = 1;
                format = "{:%F %T (%Z)}";
                tooltip-format = "<tt><small>{calendar}</small></tt>";
                smooth-scrolling-threshold = 10;
                timezones = [
                    "America/Los_Angeles"
                    "Etc/UTC"
                    "Europe/Rome"
                    "Asia/Tokyo"
                ];
                calendar = {
                    mode = "year";
                    weeks-pos = "right";
                    mode-mon-col = 4;
                };
                actions = {
                    on-click = "shift_up";
                    on-click-middle = "shift_reset";
                    on-click-right = "shift_down";
                    on-scroll-up = "tz_up";
                    on-scroll-down = "tz_down";
                };
            };

            # shows when screenshare, mic are in use
            privacy = {
                icon-size = 16;
                icon-spacing = 6;
            };

            # i have the power
            battery = {
                format = "{icon}";
                format-icons = [ "t" "v" "w" "u" ];
                tooltip-format = "{capacity}% ({timeTo})";
                states = { # used to change the color at these percentages
                    warning = 25;
                    critical = 10;
                };
            };

            # group all the control center stuff so it doesn't clutter the bar
            "group/controls" = {
                orientation = "inherit";
                drawer = {
                    transition-duration = 500;
                    transition-left-to-right = false;
                    click-to-reveal = true;
                };
                modules = [
                    "custom/controls"
                    "tray"
                    "idle_inhibitor"
                    "network"
                    "backlight"
                    "wireplumber"
                ];
            };

            # dummy icon
            "custom/controls" = {
                format = "";
                tooltip = false;
            };

            # system tray
            tray = {
                icon-size = 16;
                spacing = 4;
            };

            # prevent the system from going to sleep when this is enabled
            idle_inhibitor = {
                tooltip = false;
                format = "";
            };

            # network status. click = open nmtui
            network = {
                on-click = "kitty --detach --directory='~' nmtui";
                format = "";
                format-wifi = "";
                format-ethernet = "";
                format-linked = "";
                format-disconnected = "";
                tooltip-format = "{ifname} via {gwaddr}";
                tooltip-format-wifi = "{essid} ({signalStrength}%)";
                tooltip-format-disconnected = "Disconnected";
            };

            # display brightness. the builtin scroll to change it doesn't work so we reimplement it
            # TODO click = toggle night light?
            backlight = {
                format = "{icon}";
                format-icons = [ "F" "G" ];
                tooltip-format = "{percent}%";
                on-scroll-up = "brightnessctl set 1%+";
                on-scroll-down = "brightnessctl set 1%-";
            };

            # audio management. click = mute
            wireplumber = {
                format = "{icon}";
                format-muted = "";
                format-icons = [ "" "" "" ];
                tooltip-format = "{volume}% ({node_name})";
                on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                on-click-right = "pwvucontrol";
            };

            # power menu
            "group/power" = {
                orientation = "inherit";
                drawer = {
                    transition-duration = 500;
                    transition-left-to-right = false;
                };
                modules = [
                    "custom/power-shutdown"
                    "custom/power-logout"
                    "custom/power-sleep"
                    "custom/power-restart"
                ];
            };

            "custom/power-shutdown" = {
                format = "";
                tooltip = false;
                on-click = "shutdown now";
            };

            "custom/power-logout" = {
                format = "=";
                tooltip = false;
                on-click = "loginctl terminate-user $USER";
            };

            "custom/power-sleep" = {
                format = "Y";
                tooltip = false;
                on-click = "systemctl suspend";
            };

            "custom/power-restart" = {
                format = "Z";
                tooltip = false;
                on-click = "shutdown now -r";
            };

        };

        # formatting for waybar
        programs.waybar.style = ''
            /* setup global formatting */
            * {
                border-radius: 0;
                padding: 0;
                transition: .25s;
            }

            window#waybar { /* this has to be "waybar" */
                background: rgba(0, 0, 0, 0);
                font-size: 14px;
                font-family: sans-serif;
                color: #fff;
            }

            /* format backgrounds and drop shadow for each section */
            .modules-left,
            .modules-center,
            .modules-right {
                background-color: rgba(31, 31, 31, .6);
                box-shadow: 0 0 2px 1px rgba(26, 26, 26, 238);
                border: 2px solid rgba(255, 255, 255, .2);
                margin: 12px 12px 6px 12px;
            }

            /* workspace switcher. nuke it because default styles fuck with everything else */
            #workspaces button {
                all: unset;
                padding: 0 6px;
                color: rgba(255, 255, 255, .2);
                font-size: 14px;
                font-family: "dripicons-v2", sans-serif;
                border-radius: 0;
                transition: .25s;
            }

            /* workspace switcher on hover. nuke it because default styles fuck with everything else */
            /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
            #workspaces button:hover {
                background: rgba(255, 255, 255, .2);
            }

            /* the currently selected workspace */
            #workspaces button.active {
                color: #fff;
            }

            /* what time is it. this widget is kinda used as an anchor to determine the height of the whole bar */
            #clock {
                padding: 3px 6px;
                min-width: 192px; /* actual width/height doesn't exist, only min */
            }

            /* setup spacing for control center icons */
            #battery,
            #idle_inhibitor,
            #network,
            #backlight,
            #wireplumber,
            #custom-controls,
            #custom-power-shutdown,
            #custom-power-logout,
            #custom-power-sleep,
            #custom-power-restart {
                font-family: "dripicons-v2", sans-serif;
                padding: 0 6px;
            }

            /* control center icons that can be hovered */
            #idle_inhibitor:hover,
            #network:hover,
            #backlight:hover,
            #wireplumber:hover,
            #custom-controls:hover,
            #custom-power-shutdown:hover,
            #custom-power-logout:hover,
            #custom-power-sleep:hover,
            #custom-power-restart:hover {
                background-color: rgba(255, 255, 255, .2);
            }

            /* privacy bg = red. usually doesn't show up unless it's in use--exactly what we want */
            #privacy {
                background-color: rgba(221, 51, 68, .2);
                padding: 0 6px;
            }

            /* battery charging = green */
            #battery.charging {
                background-color: rgba(85, 187, 85, .2);
            }

            /* battery <25% = yellow (except when charging) */
            /* https://github.com/Alexays/Waybar/blob/master/resources/style.css#L138 */
            #battery.warning:not(.charging) {
                background-color: rgba(246, 206, 61, .2);
            }

            /* battery <10% = red (except when charging) */
            #battery.critical:not(.charging) {
                background-color: rgba(221, 51, 68, .2);
            }

            #tray {
                padding: 0 4px;
            }

            /* idle inhibitor enabled = green */
            #idle_inhibitor.activated {
                background-color: rgba(85, 187, 85, .2);
            }

            /* grey out the icon when network is disabled */
            #network.disabled {
                color: rgba(255, 255, 255, .2);
            }

            /* disconnected = red */
            #network.disconnected {
                background-color: rgba(221, 51, 68, .2);
            }

            /* connected & no internet = yellow */
            #network.linked {
                background-color: rgba(246, 206, 61, .2);
            }

            /* audio out muted = red */
            #wireplumber.muted {
                background-color: rgba(221, 51, 68, .2);
            }
        '';

        services.mako = {

            enable = true;
            defaultTimeout = 10000; # in ms

            # Border formatting
            borderColor = "#ffffffff";
            borderRadius = 0;
            borderSize = 2;

            font = "sans-serif 12";
            backgroundColor = "#1f1f1f99";
            margin = "24,28";
            padding = "6";

            progressColor = "#55bb55ff";

        };

        # anyrun app launcher
        programs.anyrun = {

            enable = true;

            # styling
            config.width = { fraction = 0.5; };
            config.hidePluginInfo = true;

            # if this isn't enabled you must press ESC to exit Anyrun
            config.closeOnClick = true;

            # enable all plugins except randr, stdin, and dictionary
            config.plugins = [
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libapplications.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libkidex.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/librink.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libshell.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libsymbols.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libtranslate.so"
                "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/libwebsearch.so"
            ];

            # Websearch plugin config
            extraConfigFiles."websearch.ron".text = ''
                Config(
                    prefix: "?",
                    engines: [DuckDuckGo]
                )
            '';

            # CSS theming
            extraCss = ''
                * {
                    all: unset;
                    border-radius: 0;
                }

                #window {
                    background: rgba(0, 0, 0, 0);
                    padding: 48px;
                }

                box#main {
                    margin: 48px;
                    padding: 24px;
                    background-color: rgba(31, 31, 31, .6);
                    box-shadow: 0 0 2px 1px rgba(26, 26, 26, 238);
                    border: 2px solid #fff;
                }

                #entry { /* I would center align the text, but GTK doesn't support it */
                    border-bottom: 2px solid #fff;
                    margin-bottom: 12px;
                    padding: 6px;
                    font-family: monospace;
                }

                #match {
                    padding: 4px;
                }

                #match:selected,
                #match:hover {
                    background-color: rgba(255, 255, 255, .2);
                }

                label#match-title {
                    font-weight: bold;
                }
            '';

        };

        # Enable day/night color temperature adjustment
        services.wlsunset = {
            enable = true;
            sunrise = "6:00";
            sunset = "19:00";
        };

    };

}

