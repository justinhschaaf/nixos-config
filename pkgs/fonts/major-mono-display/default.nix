{ stdenv, fetchurl }: # nixpkgs repo uses stdenvNoCC. why? idk

stdenv.mkDerivation rec {
    pname = "major-mono-display";
    version = "2018-09-27";

    src = fetchurl {
        url = "https://github.com/googlefonts/majormono/raw/ab4221e332ee158b314406b4ca01246290a9168b/fonts/MajorMonoDisplay-Regular.ttf";
        sha256 = "Py7nHCuEZPBlv5YKFIvoHWj8wTOF34dzeSj5SCCN/8Y=";
    };

    dontUnpack = true;

    # Sources:
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/fonts/3270font/default.nix
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/fonts/agave/default.nix
    installPhase = ''
        runHook preInstall

        install -D $src -t $out/share/fonts/truetype/

        runHook postInstall
    '';

}
