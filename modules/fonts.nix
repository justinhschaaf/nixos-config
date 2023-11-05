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
            fira
            fraunces
            gelasio
            helvetica-neue-lt-std
            iwona
            jost
            joypixels
            junction-font
            lexend
            liberation_ttf
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
            ubuntu_font_family
            unifont
            victor-mono
            vistafonts
            vollkorn
            work-sans
            zilla-slab
        ];

        # What fonts to use as default
        fontconfig.defaultFonts = {
            serif = [ "Blobmoji Regular" "Gelasio Regular" "Unifont" ];
            sansSerif = [ "Blobmoji Regular" "Nacelle Regular" "Unifont" ]; # TODO Vercetti
            monospace = [ "Blobmoji Regular" "Cascadia Mono Regular" "Unifont" ]; # TODO IBM Plex Mono
        };

    };
    
}