{ inputs, lib, config, pkgs, jspkgs, ... }: {

    options = {
        js.desktop.fonts.enable = lib.mkEnableOption "fonts";
    };

    config = lib.mkIf config.js.desktop.fonts.enable {

        # Accept JoyPixels' special license
        nixpkgs.config.joypixels.acceptLicense = true;

        # Fonts https://wiki.nixos.org/wiki/Fonts
        fonts = {

            # What fonts to install
            # Many here because a) i'm a font addict, and b) gimme some options like Windows
            packages = [

                # Personal package repo
                jspkgs.bayon
                jspkgs.dripicons
                jspkgs.kenney-fonts
                jspkgs.major-mono-display
                jspkgs.typewithpride
                jspkgs.vercetti

                # From nixpkgs
                pkgs.b612
                pkgs.barlow
                pkgs.cascadia-code
                pkgs.chonburi-font
                pkgs.comic-neue
                pkgs.corefonts
                pkgs.crimson-pro
                pkgs.dotcolon-fonts
                pkgs.fira
                pkgs.fraunces
                pkgs.geist-font
                pkgs.gelasio
                pkgs.helvetica-neue-lt-std
                pkgs.ibm-plex
                pkgs.iwona
                pkgs.jost
                pkgs.joypixels
                pkgs.junction-font
                pkgs.lexend
                pkgs.liberation_ttf
                pkgs.manrope
                pkgs.merriweather
                pkgs.merriweather-sans
                pkgs.monocraft
                pkgs.mplus-outline-fonts.githubRelease
                pkgs.nanum
                pkgs.norwester-font
                #pkgs.noto-fonts # I'm afraid of this adding all 200 fonts
                pkgs.noto-fonts-emoji-blob-bin
                pkgs.ostrich-sans
                pkgs.overpass
                pkgs.poly
                pkgs.prociono
                pkgs.raleway
                pkgs.recursive
                pkgs.rubik
                pkgs.scientifica
                pkgs.terminus_font
                pkgs.the-neue-black
                pkgs.ubuntu_font_family
                pkgs.unifont
                pkgs.victor-mono
                pkgs.vistafonts
                pkgs.vollkorn
                pkgs.work-sans
                pkgs.zilla-slab

            ];

            # What fonts to use as default
            fontconfig.defaultFonts = {
                serif = [
                    "Gelasio" "IBM Plex Sans Arabic" "IBM Plex Sans Devanagari"
                    "IBM Plex Sans Hebrew" "IBM Plex Sans JP" "IBM Plex Sans KR"
                    "IBM Plex Sans Thai" "Unifont"
                ];
                sansSerif = [
                    "Vercetti" "Nacelle" "IBM Plex Sans Arabic"
                    "IBM Plex Sans Devanagari" "IBM Plex Sans Hebrew" "IBM Plex Sans JP"
                    "IBM Plex Sans KR" "IBM Plex Sans Thai" "Unifont"
                ];
                monospace = [ "IBM Plex Mono" "Cascadia Mono" "Unifont" ];
                emoji = [ "Blobmoji" "Joypixels" ];
            };

        };

    };

}

