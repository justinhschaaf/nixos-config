{ inputs, lib, config, pkgs, system, ... }: {

    options.js.desktop.hyprland = {
        enable = lib.mkEnableOption "Hyprland";
        bar.enable = lib.mkEnableOption "Waybar" // { default = true; };
        bar.position = lib.mkOption {
            type = lib.types.enum ["top" "bottom" "left" "right"];
            description = "Where on the screen to position the status bar.";
            default = "top";
        };
        extraConfig = lib.mkOption {
            type = lib.types.lines;
            description = "Extra configuration text added to the end of hyprland.lua.";
            default = "";
        };
        idle.enable = lib.mkEnableOption "automatically locking the display and turning it off" // { default = true; };
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
        lockcmd = lib.mkOption {
            type = lib.types.str;
            description = "The command to execute to lock the screen.";
            default = "grim /tmp/lock.png && gm mogrify -blur 20x10 -fill black -colorize 20 /tmp/lock.png && swaylock -fklr --image /tmp/lock.png --separator-color 00000000";
            visible = false;
        };
        monitors = lib.mkOption { # https://wiki.hyprland.org/Configuring/Monitors/
            type = lib.types.lines;
            description = "The display configuration for this device.";
            default = ''
                hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
                '';
        };
        screenshot.output = lib.mkOption {
            type = lib.types.str;
            description = "Where screenshots taken should be saved by default, relative to the user's home directory.";
            default = "Pictures/Screenshots";
        };
        sunrise = lib.mkOption {
            type = lib.types.str;
            description = "What time wlsunset should shift from warm to cool colors.";
            default = "7:00";
        };
        sunset = lib.mkOption {
            type = lib.types.str;
            description = "What time wlsunset should shift from cool to warm colors.";
            default = "19:00";
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

        # Let us sign back in after locking the computer https://github.com/NixOS/nixpkgs/issues/143365
        # Using mkDefault so laptop can override it
        security.pam.services.swaylock = lib.mkDefault {};

        # Set UWSM Hyprland as the default session
        # Unfortunately this has no effect on greetd tuigreet
        services.displayManager.defaultSession = "hyprland-uwsm";

        # Enable Hyprland
        programs.hyprland = {
            enable = true;
            xwayland.enable = true;
            withUWSM = true;
        };

        # start waybar with systemd
        programs.waybar.enable = config.js.desktop.hyprland.bar.enable;

        # enable hypridle
        services.hypridle.enable = config.js.desktop.hyprland.idle.enable;

        environment.systemPackages = with pkgs; [

            # Hyprland Stuff/Basic System Functionality
            anyrun
            awww
            brightnessctl
            libnotify
            mako
            polkit_gnome
            udiskie
            # https://github.com/ErikReider/SwayOSD

            # Clipboard
            wl-clipboard
            wl-clipboard-x11
            wl-clip-persist

            # Screenshots
            grim
            grimblast
            hyprpicker
            jq
            satty
            slurp

            # Sleep
            swaylock
            graphicsmagick

        ];

        # Set Hyprland environment variables
        environment.sessionVariables = let
            gapsOut = if config.js.desktop.hyprland.bar.enable then
                    if config.js.desktop.hyprland.bar.position == "top" then "6, 12, 12, 12"
                    else if config.js.desktop.hyprland.bar.position == "right" then "12, 6, 12, 12"
                    else if config.js.desktop.hyprland.bar.position == "bottom" then "12, 12, 6, 12"
                    else "12, 12, 12, 6"
                else "12, 12, 12, 12";
            hyprlandCfg = pkgs.writeText "hyprland.lua"
                ''
                -- Refer to the wiki for more information.
                -- https://wiki.hypr.land/configuring/

                -- Please note not all available settings / options are set here.
                -- For a full list, see the wiki

                ------------------
                ---- MONITORS ----
                ------------------

                -- See https://wiki.hypr.land/configuring/core/monitors/
                ${config.js.desktop.hyprland.monitors}

                ---------------------
                ---- MY PROGRAMS ----
                ---------------------

                local lock = "${config.js.desktop.hyprland.lockcmd}"
                local satty = "satty --filename - --fullscreen --copy-command 'wl-copy' --output-filename \"${config.js.desktop.hyprland.screenshot.output}/satty-$(date '+%Y%m%d-%H%M%S').png\""

                -------------------
                ---- AUTOSTART ----
                -------------------

                -- See https://wiki.hypr.land/configuring/core/autostart/

                hl.on("hyprland.start", function ()
                  hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
                  hl.exec_cmd("udiskie -A -f thunar") -- -A = no automount
                  hl.exec_cmd("mako")
                  hl.exec_cmd("awww-daemon")
                  hl.exec_cmd("fcitx5 -d") -- -d = daemon
                  hl.exec_cmd("hypridle")
                end)

                -----------------------
                ----- PERMISSIONS -----
                -----------------------

                -- See https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/
                -- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
                -- for security reasons

                -- hl.config({
                --   ecosystem = {
                --     enforce_permissions = true,
                --   },
                -- })

                -- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
                -- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
                -- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


                ----------------
                ---- CONFIG ----
                ----------------

                -- Refer to https://wiki.hypr.land/configuring/core/config-options/
                hl.config({
                    general = {
                        gaps_in  = 4,
                        gaps_out = ${gapsOut},

                        border_size = 2,

                        col = {
                            active_border   = "rgba(ffffffff)",
                            inactive_border = "rgba(595959aa)",
                        },

                        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
                        resize_on_border = true,

                        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
                        allow_tearing = false,

                        layout = "dwindle",
                    },

                    decoration = {
                        rounding = 0,

                        -- Change transparency of focused and unfocused windows
                        active_opacity   = 1.0,
                        inactive_opacity = 1.0,

                        shadow = {
                            enabled      = true,
                            range        = 4,
                            render_power = 3,
                            color        = 0xee1a1a1a,
                        },

                        blur = {
                            enabled   = true,
                            size      = 10,
                            passes    = 2,
                            vibrancy  = 0.1696,
                        },
                    },

                    animations = {
                        enabled = true,
                    },

                    -- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
                    dwindle = {
                        preserve_split = true, -- You probably want this
                    },

                    -- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
                    master = {
                        allow_small_split = true,
                        new_status = "slave",
                        center_master_fallback = "right",
                    },

                    -- Fix xwayland apps at 1.5 scale, nearest neighbor is not necessarily better
                    -- https://wiki.hyprland.org/Configuring/Variables/#xwayland
                    xwayland = {
                        force_zero_scaling = true,
                    },

                    debug = {
                        -- This is necessary to force Hyprland to stfu about using 1.5 scale
                        -- IT WAS WORKING FINE BEFORE V34
                        -- https://github.com/hyprwm/Hyprland/issues/4225
                        disable_scale_checks = true,

                        -- move error messages to the bottom of the screen.
                        error_position = 1,
                    },

                    -- Disable extra popups
                    ecosystem = {
                        no_update_news = true,
                        no_donation_nag = true,
                    },

                    misc = {
                        force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
                        disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
                    },

                    input = {
                        kb_layout  = "us",
                        follow_mouse = 1,
                        numlock_by_default = true,
                        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
                        touchpad = {
                            natural_scroll = false,
                        },
                    },
                })

                ---------------------
                ---- KEYBINDINGS ----
                ---------------------

                local mainMod = "SUPER" -- Sets "Windows" key as main modifier

                -- Application keybinds, see https://wiki.hypr.land/configuring/core/binds/ for more
                hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("anyrun"))
                hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty"))
                hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
                hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("missioncenter"))
                hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("flatpak run dev.krtirtho.Flemozi")) -- same as windows
                hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("notify-send -a 'hyprpicker' \"Color: $(hyprpicker -anr)\" 'The selected color has been copied to your clipboard.'")) -- same as powertoys

                -- System keybinds
                hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(lock))

                -- Screenshot
                hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast --freeze save area - | " .. satty))
                hl.bind(mainMod .. " + CTRL + Print", hl.dsp.exec_cmd("grimblast --freeze save active - | " .. satty))
                hl.bind(mainMod .. " + ALT + Print", hl.dsp.exec_cmd("grimblast --freeze save output - | " .. satty))

                -- Application interactions
                hl.bind(mainMod .. " + Q", hl.dsp.window.close())
                hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
                hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
                hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
                hl.bind(mainMod .. " + M", hl.dsp.layout("swapwithmaster"))    -- master only
                hl.bind(mainMod .. " + SHIFT + left", hl.dsp.layout("swapprev"))    -- master only
                hl.bind(mainMod .. " + SHIFT + right ", hl.dsp.layout("swapnext"))    -- master only

                -- Move focus with mainMod + arrow keys
                hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
                hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
                hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
                hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

                -- Switch workspaces with mainMod + [0-9]
                -- Move active window to a workspace with mainMod + SHIFT + [0-9]
                for i = 1, 10 do
                    local key = i % 10 -- 10 maps to key 0
                    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
                    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
                end

                -- Scroll through existing workspaces with mainMod + scroll
                hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
                hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

                -- Move/resize windows with mainMod + LMB/RMB and dragging
                hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
                hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

                -- Laptop multimedia keys for volume and LCD brightness
                hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
                hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
                hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
                hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
                hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                  { locked = true, repeating = true })
                hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                  { locked = true, repeating = true })

                -- Requires playerctl
                hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
                hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
                hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
                hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

                --------------------------------
                ---- WINDOWS AND WORKSPACES ----
                --------------------------------

                -- See https://wiki.hypr.land/configuring/core/rules/

                -- Example window rules that are useful

                local suppressMaximizeRule = hl.window_rule({
                    -- Ignore maximize requests from all apps. You'll probably like this.
                    name  = "suppress-maximize-events",
                    match = { class = ".*" },

                    suppress_event = "maximize",
                })
                -- suppressMaximizeRule:set_enabled(false)

                hl.window_rule({
                    -- Fix some dragging issues with XWayland
                    name  = "fix-xwayland-drags",
                    match = {
                        class      = "^$",
                        title      = "^$",
                        xwayland   = true,
                        float      = true,
                        fullscreen = false,
                        pin        = false,
                    },

                    no_focus = true,
                })

                -- Get KDE file picker to show up properly
                -- At least I can actually paste in a file path now
                -- https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-2/
                hl.window_rule({
                    name  = "maximize-kde-fileportal",
                    match = { class = "^(org.freedesktop.impl.portal.desktop.kde)$" },
                    float = true,
                    center = true,
                    maximize = true,
                })

                -- float, center, maximize screenshot save window
                hl.window_rule({
                    name  = "maximize-satty",
                    match = {
                        class = "satty",
                        title = "Save Image As",
                    },
                    float = true,
                    center = true,
                    maximize = true,
                })

                -- fix issues with steam repositioning itself for no fucking reason
                -- https://thinglab.org/2026/01/hyprland_steam_windowrule/
                hl.window_rule({
                    name  = "fix-steam",
                    match = {
                        class = "steam",
                        initial_title = "Steam",
                        float = true,
                    },
                    float = false,
                    maximize = true,
                })

                ${config.js.desktop.hyprland.extraConfig}
                '';
        in {

            HYPRLAND_CONFIG = "${hyprlandCfg}";

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

        } // lib.attrsets.optionalAttrs config.js.hardware.nvidia.gpu.enable {

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

