{ inputs, lib, osConfig, config, pkgs, ... }: {

    imports = [ inputs.hyprland.homeManagerModules.default ];

    options.js.hm.hyprland.enable = lib.mkOption { default = osConfig.js.desktop.hyprland.enable; };

    # Hyprland and helper applications
    config = lib.mkIf config.js.hm.hyprland.enable {

        # configure hypridle
        # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle/
        # https://home-manager-options.extranix.com/?query=hypridle&release=release-24.05
        services.hypridle.enable = osConfig.js.desktop.hyprland.idle.enable;
        services.hypridle.settings = {
            general = {
                lock_cmd = "pidof swaylock || ${osConfig.js.desktop.hyprland.lockcmd}";
                before_sleep_cmd = "loginctl lock-session";
            };
            listener = [{
                timeout = osConfig.js.desktop.hyprland.idle.lockTimeout;
                on-timeout = "loginctl lock-session";
            } {
                timeout = osConfig.js.desktop.hyprland.idle.screenOffTimeout;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
            }];
        };

        # setup waybar
        programs.waybar.enable = true;
        programs.waybar.settings.taskbar = {

            # where do we put it
            layer = "bottom";
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
                ] ++ lib.optionals osConfig.js.desktop.hyprland.idle.enable [
                    # only enable if the screen will idle itself
                    # placed in the middle because i care about the order
                    "idle_inhibitor"
                ] ++ [
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

        services.mako.enable = true;
        services.mako.settings = {

            default-timeout = 10000; # in ms

            # Border formatting
            border-color = "#ffffffff";
            border-radius = 0;
            border-size = 2;

            font = "sans-serif 12";
            background-color = "#1f1f1f99";
            margin = "24,28";
            padding = "6";

            progress-color = "#55bb55ff";

        };

        # anyrun app launcher
        programs.anyrun.enable = true;
        programs.anyrun.config = {
            # styling
            width = { fraction = 0.5; };
            hidePluginInfo = true;

            # if this isn't enabled you must press ESC to exit Anyrun
            closeOnClick = true;

            # enable all plugins except randr, stdin, and dictionary
            plugins = [
                "${pkgs.anyrun}/lib/libapplications.so"
                "${pkgs.anyrun}/lib/libkidex.so"
                "${pkgs.anyrun}/lib/libnix_run.so"
                "${pkgs.anyrun}/lib/librink.so"
                "${pkgs.anyrun}/lib/libshell.so"
                "${pkgs.anyrun}/lib/libsymbols.so"
                "${pkgs.anyrun}/lib/libtranslate.so"
                "${pkgs.anyrun}/lib/libwebsearch.so"
            ];
        };

        # Websearch plugin config
        programs.anyrun.extraConfigFiles."websearch.ron".text = ''
            Config(
                prefix: "?",
                engines: [DuckDuckGo]
            )
        '';

        # CSS theming
        programs.anyrun.extraCss = ''
            * {
                all: unset;
                border-radius: 0;
            }

            window {
                background: rgba(0, 0, 0, 0);
                padding: 48px;
            }

            box.main {
                margin: 48px;
                padding: 24px;
                background-color: rgba(31, 31, 31, .6);
                box-shadow: 0 0 2px 1px rgba(26, 26, 26, 238);
                border: 2px solid #fff;
            }

            text { /* I would center align the text, but GTK doesn't support it */
                border-bottom: 2px solid #fff;
                margin-bottom: 12px;
                padding: 6px;
                font-family: monospace;
            }

            .match {
                padding: 4px;
            }

            .match:selected,
            .match:hover {
                background-color: rgba(255, 255, 255, .2);
            }

            label.match-title {
                font-weight: bold;
            }
        '';

        # Enable day/night color temperature adjustment
        services.wlsunset = {
            enable = true;
            sunrise = osConfig.js.desktop.hyprland.sunrise;
            sunset = osConfig.js.desktop.hyprland.sunset;
        };

    };

}

