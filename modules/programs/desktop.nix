{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.desktop.enable = lib.mkEnableOption "desktop applications";
    };

    config = lib.mkIf config.js.programs.desktop.enable {

        environment.systemPackages = [

            # Applications
            pkgs.kitty
            pkgs.gnome.gnome-system-monitor
            pkgs.gparted
            pkgs.wdisplays
            pkgs.cinnamon.xreader
            pkgs.mpv

        ];

        # mpv scripts
        nixpkgs.overlays = [
            (self: super: {
                mpv = super.mpv.override {
                    scripts = with self.mpvScripts; [
                        mpris
                        uosc
                        visualizer
                        vr-reversal
                    ];
                };
            })
        ];

        # Flatpak config
        # TODO wayland by default
        services.flatpak = {

            # Add repo
            remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

            # Add Flatpaks. Format is <repo>:<ref>/<arch>/<branch>:<commit>
            # Branch is almost always "stable"
            packages = [
                "flathub:app/app.drey.Warp//stable"
                "flathub:app/com.github.tchx84.Flatseal//stable"
                "flathub:app/org.mozilla.firefox//stable"
                "flathub:app/org.nomacs.ImageLounge//stable"
            ];

        };

    };

}

