{ stdenv, fetchgit }: # nixpkgs repo uses stdenvNoCC. why? idk

stdenv.mkDerivation rec {
    pname = "dripicons";
    version = "2";

    src = fetchgit {
        url = "https://github.com/amitjakhu/dripicons.git";
        sparseCheckout = [ "webfont/fonts" ];
        sha256 = "fNfZdUHvF5OIG7MOqbisu8/ZOIpOPCqbTF0noSvIp+0=";
    };

    # Not specifying the full source directory here yields a "install: missing file operand" error
    installPhase = ''
        runHook preInstall

        install -D -t $out/share/fonts/truetype/ $src/webfont/fonts/*.ttf
        install -D -t $out/share/fonts/woff/ $src/webfont/fonts/*.woff

        runHook postInstall
    '';

}
