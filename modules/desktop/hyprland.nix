{ inputs, lib, config, pkgs, ... }: {

    imports = [
        inputs.hyprland.nixosModules.default
    ];

    options.js.desktop.hyprland = {
        enable = lib.mkEnableOption "Hyprland";
        idle.enable = lib.mkEnableOption "automatically locking the display and turning it off";
        idle.lockTimeout = lib.mkOption {
            type = lib.types.ints.positive;
            description = "How long to wait before locking the computer when there's no activity, in seconds.";
            default = 300;
        };
        idle.screenOffTimeout = lib.mkOption {
            type = lib.types.ints.positive;
            description = "How long to wait before turning the screen off when there's no activity, in seconds.";
            default = 330;
        };
        monitors = lib.mkOption { # https://wiki.hyprland.org/Configuring/Monitors/
            type = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
            description = "The display configuration for this device.";
            default = ",preferred,auto,auto";
        };
        screenshot.output = lib.mkOption {
            type = lib.types.str;
            description = "Where screenshots taken should be saved by default, relative to the user's home directory.";
            default = "Pictures/Screenshots";
        };
        lockcmd = lib.mkOption {
            type = lib.types.str;
            description = "The command to execute to lock the screen.";
            default = "grim /tmp/lock.png && gm mogrify -blur 20x10 -fill black -colorize 20 /tmp/lock.png && swaylock -fklr --image /tmp/lock.png --separator-color 00000000";
            visible = false;
        };
    };

    config = lib.mkIf config.js.desktop.hyprland.enable {

        # Enable XDG Desktop Portal
        xdg.portal.enable = true;

        # Add KDE portal for file picker
        # Hyprland is already added by the module for it
        xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

        # Setting 2 defaults uses KDE for everything else Hyprland can't do
        # https://forum.manjaro.org/t/link-in-flatpak-apps-wont-open-on-click-since-anymore-last-update/149907/22
        xdg.portal.config.common.default = [ "hyprland" "kde" ];

        # Properly pass bin locations to systemd so desktop portals can access
        # Mimetype handlers and let Flatpaks open the browser
        # https://github.com/NixOS/nixpkgs/issues/189851#issuecomment-1759954096
        systemd.user.extraConfig = ''
            DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        '';

        # Let us sign back in after locking the computer https://github.com/NixOS/nixpkgs/issues/143365
        # Using mkDefault so laptop can override it
        security.pam.services.swaylock = lib.mkDefault {};

        # Enable Hyprland. It has to be enabled on the system level too
        programs.hyprland = {
            enable = true;
            xwayland.enable = true;
            withUWSM = true;

            # Add plugins for better multi-monitor support
            plugins = [
                inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
            ];

            # Hyprland config
            settings = {

                # Please note not all available settings / options are set here.
                # For a full list, see the wiki

                # See https://wiki.hyprland.org/Configuring/Monitors/
                # Wdisplays exists and is installed, but config doesn't save between restarts
                monitor = config.js.desktop.hyprland.monitors;

                # This is necessary to force Hyprland to stfu about using 1.5 scale
                # IT WAS WORKING FINE BEFORE V34
                # https://github.com/hyprwm/Hyprland/issues/4225
                debug.disable_scale_checks = true;

                # Fix xwayland apps at 1.5 scale, nearest neighbor is not necessarily better
                # https://wiki.hyprland.org/Configuring/Variables/#xwayland
                xwayland.force_zero_scaling = true;

                # Lock command https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
                "$lock" = config.js.desktop.hyprland.lockcmd;

                # Screenshot editor
                "$satty" = "satty --filename - --fullscreen --copy-command 'wl-copy' --output-filename \"${config.js.desktop.hyprland.screenshot.output}/satty-$(date '+%Y%m%d-%H%M%S').png\"";

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

                windowrulev2 = [
                    # Get KDE file picker to show up properly
                    # At least I can actually paste in a file path now
                    # https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
                    "float,class:^(org.freedesktop.impl.portal.desktop.kde)$"
                    "center,class:^(org.freedesktop.impl.portal.desktop.kde)$"
                    "maximize,class:^(org.freedesktop.impl.portal.desktop.kde)$"

                    # Handling overrides for xwaylandvideobridge
                    # https://wiki.hyprland.org/Useful-Utilities/Screen-Sharing/
                    "opacity 0.0 override, class:^(xwaylandvideobridge)$"
                    "noanim, class:^(xwaylandvideobridge)$"
                    "noinitialfocus, class:^(xwaylandvideobridge)$"
                    "maxsize 1 1, class:^(xwaylandvideobridge)$"
                    "noblur, class:^(xwaylandvideobridge)$"
                    "nofocus, class:^(xwaylandvideobridge)$"
                ];

                # See https://wiki.hyprland.org/Configuring/Variables/ for more
                gestures.workspace_swipe = false;
                misc.force_default_wallpaper = 0; # No more anime girl jumpscares

                # Disable extra popups
                ecosystem = {
                    no_update_news = true;
                    no_donation_nag = true;
                };

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
                    resize_on_border = true;
                    layout = "dwindle";

                    "col.active_border" = "rgba(ffffffff)";
                    "col.inactive_border" = "rgba(595959aa)";
                };

                decoration = {
                    rounding = 0;

                    blur = {
                        enabled = true;
                        size = 10;
                        passes = 2;
                        new_optimizations = true;
                    };

                    shadow = {
                        enabled = true;
                        range = 4;
                        render_power = 3;
                        color = "rgba(1a1a1aee)";
                    };
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
                    "$mainMod, 1, split-workspace, 1"
                    "$mainMod, 2, split-workspace, 2"
                    "$mainMod, 3, split-workspace, 3"
                    "$mainMod, 4, split-workspace, 4"
                    "$mainMod, 5, split-workspace, 5"
                    "$mainMod, 6, split-workspace, 6"
                    "$mainMod, 7, split-workspace, 7"
                    "$mainMod, 8, split-workspace, 8"
                    "$mainMod, 9, split-workspace, 9"
                    "$mainMod, 0, split-workspace, 10"

                    # Move active window to a workspace with mainMod + SHIFT + [0-9]
                    "$mainMod SHIFT, 1, split-movetoworkspace, 1"
                    "$mainMod SHIFT, 2, split-movetoworkspace, 2"
                    "$mainMod SHIFT, 3, split-movetoworkspace, 3"
                    "$mainMod SHIFT, 4, split-movetoworkspace, 4"
                    "$mainMod SHIFT, 5, split-movetoworkspace, 5"
                    "$mainMod SHIFT, 6, split-movetoworkspace, 6"
                    "$mainMod SHIFT, 7, split-movetoworkspace, 7"
                    "$mainMod SHIFT, 8, split-movetoworkspace, 8"
                    "$mainMod SHIFT, 9, split-movetoworkspace, 9"
                    "$mainMod SHIFT, 0, split-movetoworkspace, 10"

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

        # enable hypridle
        js.desktop.hyprland.idle.enable = lib.mkDefault true;
        services.hypridle.enable = config.js.desktop.hyprland.idle.enable;

        environment.systemPackages = [

            # Hyprland Stuff/Basic System Functionality
            pkgs.brightnessctl
            pkgs.libnotify
            pkgs.mako
            pkgs.polkit_gnome
            pkgs.swww
            pkgs.udiskie
            pkgs.waybar
            pkgs.kdePackages.xwaylandvideobridge
            inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins
            # https://github.com/ErikReider/SwayOSD

            # Clipboard
            pkgs.wl-clipboard
            pkgs.wl-clipboard-x11
            pkgs.wl-clip-persist

            # Screenshots
            pkgs.grim
            pkgs.grimblast
            pkgs.hyprpicker
            pkgs.jq
            pkgs.satty
            pkgs.slurp

            # Sleep
            pkgs.swaylock
            pkgs.graphicsmagick

        ];

        # Set Hyprland environment variables
        environment.sessionVariables = {

            # Tell XDG we're on Wayland
            XDG_SESSION_TYPE = "wayland";

            # Tell Electron apps to use Wayland
            NIXOS_OZONE_WL = "1";

            # Tell each toolkit to use Wayland
            # https://wiki.hyprland.org/Configuring/Environment-variables/#toolkit-backend-variables
            GDK_BACKEND = "wayland,x11,*";
            QT_QPA_PLATFORM = "wayland;xcb";
            SDL_VIDEODRIVER = "wayland";
            CLUTTER_BACKEND = "wayland";

            # Unset GTK_IM_MODULE so apps can figure it out themselves
            GTK_IM_MODULE="";

        } // lib.attrsets.optionalAttrs config.js.hardware.nvidia.enable {

            # Recommended NVIDIA variables
            # https://wiki.hyprland.org/Nvidia/#environment-variables
            "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
            GBM_BACKEND = "nvidia-drm";
            LIBVA_DRIVER_NAME = "nvidia";

        };

        # Create the folder for screenshot output
        # https://wiki.nixos.org/wiki/Systemd/User_Services
        # https://superuser.com/a/1269158
        systemd.user.services."jshot-mkdir" = {
            enable = true;
            description = "Creates the screenshot output folder if it doesn't already exist.";
            wantedBy = [ "default.target" ];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
            };
            script = ''
                mkdir -p "${config.js.desktop.hyprland.screenshot.output}"
            '';
        };

    };

}

