{ inputs, lib, config, pkgs, ... }: {

    imports = [
        inputs.hyprland.nixosModules.default
    ];

    options = {
        js.desktop.hyprland.enable = lib.mkEnableOption "Hyprland";
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
        };

        # enable hypridle
        services.hypridle.enable = true;

        environment.systemPackages = [

            # Hyprland Stuff/Basic System Functionality
            pkgs.brightnessctl
            pkgs.libnotify
            pkgs.mako
            pkgs.polkit_gnome
            pkgs.swww
            pkgs.udiskie
            pkgs.waybar
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

        } // lib.attrsets.optionalAttrs config.js.hardware.nvidia.enable {

            # Recommended NVIDIA variables
            # https://wiki.hyprland.org/Nvidia/#environment-variables
            "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
            GBM_BACKEND = "nvidia-drm";
            LIBVA_DRIVER_NAME = "nvidia";

        };

    };

}

