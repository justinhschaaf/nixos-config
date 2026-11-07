{ stdenv, fetchgit }: # nixpkgs repo uses stdenvNoCC. why? idk

stdenv.mkDerivation rec {
    pname = "bayon";
    version = "2021-05-21";

    src = fetchgit {
        url = "https://github.com/danhhong/Bayon.git";
        sparseCheckout = [ "Release/ttf" ];
        sha256 = "mUSnasvOh/mic+Y0rvW2LK4eeUEs7uPmUUSagJgCb3c=";
    };

    # Not specifying the full source directory here yields a "install: missing file operand" error
    installPhase = ''
        runHook preInstall

        install -D -t $out/share/fonts/truetype/ $src/Release/ttf/*.ttf

        runHook postInstall
    '';

}
