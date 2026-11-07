{ stdenv, fetchzip }: # nixpkgs repo uses stdenvNoCC. why? idk

stdenv.mkDerivation rec {
    pname = "typewithpride";
    version = "1.005";

    src = fetchzip {
        url = "https://github.com/Fontself/TypeWithPride/releases/download/${version}/Gilbert_${version}_alpha.zip";
        sha256 = "YsoXUba0zo6DHszGByHb1SHpX0MvFVXvYBwpm4q2ZbE=";
        stripRoot = false;
    };

    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/fonts/3270font/default.nix
    # `install` is a default Linux command, i spent an hour looking for it in the context of nix... fml
    installPhase = ''
        runHook preInstall

        install -D -t $out/share/fonts/opentype/ *.otf

        runHook postInstall
    '';

}
