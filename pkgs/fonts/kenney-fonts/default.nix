{ stdenv, fetchgit }: # nixpkgs repo uses stdenvNoCC. why? idk

stdenv.mkDerivation rec {
    pname = "kenney-fonts";
    version = "1.0";

    src = fetchgit {
        url = "https://github.com/ereborstudios/kenney-fonts.git";
        sha256 = "V5qcuVj28+UfKuzYnWIJa7Z2k65UgnUeVB+VR+Dvjrk=";
    };

    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/fonts/3270font/default.nix
    # `install` is a coreutils command, i spent an hour looking for it in the context of nix... fml
    installPhase = ''
        runHook preInstall

        install -D -t $out/share/fonts/truetype/ $src/*.ttf

        runHook postInstall
    '';

}
