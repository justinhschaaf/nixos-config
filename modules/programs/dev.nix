{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.dev.enable = lib.mkEnableOption "dev tools";
    };

    config = lib.mkIf config.js.programs.dev.enable {
    
        # System packages
        environment.systemPackages = with pkgs; [

            # Let us actually write to Git
            git-credential-manager
            gitnuro

            # Editors
            jetbrains-toolbox # Fleet is missing from Nixpkgs

            # Java
            maven

            # JS
            nodePackages.nodejs
            yarn-berry

            # Rust
            rustup # includes cargo

            # Misc
            activitywatch
            #etcher # https://github.com/NixOS/nixpkgs/pull/295853
            gnome-boxes
            tio
            vial

        ];

        services.flatpak.packages = [
            # Install Cura via Flatpak instead of Nixpkgs, see below for why
            # https://github.com/NixOS/nixpkgs/pull/327976#issuecomment-2274977353
            # https://github.com/NixOS/nixpkgs/issues/186570
            "flathub:app/com.ultimaker.cura//stable"
        ];

        programs.git = {
            enable = true;
            config.credential.credentialStore = "cache";
            config.init.defaultBranch = "main";
        };

        # Allow JetBrains applications to be run from Toolbox
        # https://nixos.wiki/wiki/Jetbrains_Tools
        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
            SDL
            SDL2
            SDL2_image
            SDL2_mixer
            SDL2_ttf
            SDL_image
            SDL_mixer
            SDL_ttf
            alsa-lib
            at-spi2-atk
            at-spi2-core
            atk
            bzip2
            cairo
            cups
            curlWithGnuTls
            dbus
            dbus-glib
            desktop-file-utils
            e2fsprogs
            expat
            flac
            fontconfig
            freeglut
            freetype
            fribidi
            fuse
            fuse3
            gdk-pixbuf
            glew110
            glib
            gmp
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-ugly
            gst_all_1.gstreamer
            gtk2
            harfbuzz
            icu
            keyutils.lib
            libGL
            libGLU
            libappindicator-gtk2
            libcaca
            libcanberra
            libcap
            libclang.lib
            libdbusmenu
            libdrm
            libgcrypt
            libgpg-error
            libidn
            libjack2
            libjpeg
            libmikmod
            libogg
            libpng12
            libpulseaudio
            librsvg
            libsamplerate
            libthai
            libtheora
            libtiff
            libudev0-shim
            libusb1
            libuuid
            libvdpau
            libvorbis
            libvpx
            libxcrypt-legacy
            libxkbcommon
            libxml2
            mesa
            nspr
            nss
            openssl
            p11-kit
            pango
            pixman
            python3
            speex
            stdenv.cc.cc
            tbb
            udev
            vulkan-loader
            wayland
            xorg.libICE
            xorg.libSM
            xorg.libX11
            xorg.libXScrnSaver
            xorg.libXcomposite
            xorg.libXcursor
            xorg.libXdamage
            xorg.libXext
            xorg.libXfixes
            xorg.libXft
            xorg.libXi
            xorg.libXinerama
            xorg.libXmu
            xorg.libXrandr
            xorg.libXrender
            xorg.libXt
            xorg.libXtst
            xorg.libXxf86vm
            xorg.libpciaccess
            xorg.libxcb
            xorg.xcbutil
            xorg.xcbutilimage
            xorg.xcbutilkeysyms
            xorg.xcbutilrenderutil
            xorg.xcbutilwm
            xorg.xkeyboardconfig
            xz
            zlib
        ];

    };

}

