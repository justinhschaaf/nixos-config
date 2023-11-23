{ inputs, config, pkgs, ... }:

{

    # Accept JoyPixels' special license
    nixpkgs.config.joypixels.acceptLicense = true;

    # Fonts https://nixos.wiki/wiki/Fonts
    fonts = {

        # What fonts to install
        # Many here because a) i'm a font addict, and b) gimme some options like Windows
        packages = with pkgs; [
            b612
            barlow
            cascadia-code
            chonburi-font
            comic-neue
            corefonts
            crimson-pro
            dotcolon-fonts
            justinhs.dripicons
            fira
            fraunces
            gelasio
            helvetica-neue-lt-std
            ibm-plex
            iwona
            jost
            joypixels
            junction-font
            justinhs.kenney-fonts
            lexend
            liberation_ttf
            justinhs.major-mono-display
            manrope
            merriweather
            merriweather-sans
            monocraft
            mplus-outline-fonts.githubRelease
            nanum
            norwester-font
            #noto-fonts # I'm afraid of this adding all 200 fonts
            noto-fonts-emoji-blob-bin
            ostrich-sans
            overpass
            poly
            prociono
            raleway
            recursive
            rubik
            scientifica
            the-neue-black
            justinhs.typewithpride
            ubuntu_font_family
            unifont
            justinhs.vercetti
            victor-mono
            vistafonts
            vollkorn
            work-sans
            zilla-slab
        ];

        # What fonts to use as default
        fontconfig.defaultFonts = {
            serif = [ "Gelasio" "Unifont" ];
            sansSerif = [ "Vercetti" "Nacelle" "Unifont" ];
            monospace = [ "IBM Plex Mono" "Cascadia Mono" "Unifont" ];
            emoji = [ "Blobmoji" ];
        };

    };
    
}