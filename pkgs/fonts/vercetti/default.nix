{ stdenv, fetchzip }: # nixpkgs repo uses stdenvNoCC. why? idk

stdenv.mkDerivation rec {
    pname = "vercetti";
    version = "1.001";

    src = fetchzip {
        url = "https://filipposfragkogiannis.com/wp-content/uploads/Vercetti-Regular.zip";
        sha256 = "l/8JEw5RwYB4EnL2yKWukm8t/+Kk3/BtJ5zNeEeldTk=";
        stripRoot = false;
    };

    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/fonts/3270font/default.nix
    # `install` is a default Linux command, i spent an hour looking for it in the context of nix... fml
    installPhase = ''
        runHook preInstall

        install -D -t $out/share/fonts/opentype/ */Vercetti-Regular.otf
        install -D -t $out/share/fonts/truetype/ */Vercetti-Regular.ttf

        runHook postInstall
    '';

}
