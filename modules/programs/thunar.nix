{ inputs, lib, config, pkgs, ... }: {

    options.js.programs.thunar.enable = lib.mkEnableOption "Thunar";

    config = lib.mkIf config.js.programs.thunar.enable {

        # Enable GVFS and Tumbler for Thunar features
        services.gvfs.enable = true;
        services.tumbler.enable = true;

        # Enable thunar here instead of using it with packages
        # see https://nixos.org/manual/nixos/stable/#sec-xfce-thunar-plugins
        programs.thunar = {
            enable = true;
            plugins = with pkgs.xfce; [
                thunar-archive-plugin
                thunar-media-tags-plugin
                thunar-volman
            ];
        };

        environment.systemPackages = with pkgs; [

            # extra file systems
            sshfs

            # Download file thumbnailers
            f3d
            ffmpegthumbnailer
            libgsf
            poppler
            webp-pixbuf-loader

        ];

    };

}
