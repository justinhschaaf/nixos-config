{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.desktop.enable = lib.mkEnableOption "desktop applications";
    };

    config = lib.mkIf config.js.programs.desktop.enable {

        environment.systemPackages = with pkgs; [

            # System Utils
            kitty
            gnome.gnome-system-monitor
            gparted
            wdisplays

            # File Viewers
            cinnamon.xreader
            mpv
            nomacs

            # Browsers
            firefox
            ungoogled-chromium

            # Other
            localsend

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
        services.flatpak.remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Allow running AppImages https://wiki.nixos.org/wiki/Appimage
        boot.binfmt.registrations.appimage = {
            wrapInterpreterInShell = false;
            interpreter = "${pkgs.appimage-run}/bin/appimage-run";
            recognitionType = "magic";
            offset = 0;
            mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
            magicOrExtension = ''\x7fELF....AI\x02'';
        };

    };

}

