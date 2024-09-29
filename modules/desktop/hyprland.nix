{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.desktop.hyprland.enable = lib.mkEnableOption "Hyprland";
    };

    config = lib.mkIf config.js.desktop.hyprland.enable {

        # XDG Desktop Portal
        xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
                xdg-desktop-portal-hyprland # Needed for screen sharing
                kdePackages.xdg-desktop-portal-kde # Needed for file picker
            ];
            config.common = {
                # Setting 2 defaults uses KDE for everything else Hyprland can't do
                # https://forum.manjaro.org/t/link-in-flatpak-apps-wont-open-on-click-since-anymore-last-update/149907/22
                default = [ "hyprland" "kde" ];
            };
        };

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

        # enable waybar for the system top bar
        programs.waybar.enable = true;

        environment.systemPackages = [
            
            # Hyprland Stuff/Basic System Functionality
            pkgs.brightnessctl
            pkgs.hyprland
            pkgs.libnotify
            pkgs.mako
            pkgs.polkit_gnome
            pkgs.swww
            pkgs.udiskie
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
            pkgs.sway-audio-idle-inhibit
            pkgs.swayidle
            pkgs.swaylock
            pkgs.graphicsmagick

        ];

        # Tell Electron apps to use Wayland
        environment.sessionVariables.NIXOS_OZONE_WL = "1";
    
    };

}

