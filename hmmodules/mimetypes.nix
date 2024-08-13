{ inputs, lib, osConfig, config, pkgs, ... }: {

    # https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html
    options = let 
        mimeAppsOption = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
        };
    in {
        js.hm.mime.enable = lib.mkOption { default = osConfig.js.programs.desktop.enable; };
        js.hm.mime.apps.audio = mimeAppsOption;
        js.hm.mime.apps.browser = mimeAppsOption;
        js.hm.mime.apps.docs = mimeAppsOption;
        js.hm.mime.apps.image = mimeAppsOption;
        js.hm.mime.apps.mail = mimeAppsOption;
        js.hm.mime.apps.text = mimeAppsOption;
        js.hm.mime.apps.video = mimeAppsOption;
        js.hm.mime.override = lib.mkOption { default = {}; };
    };

    config = lib.mkIf config.js.hm.mime.enable {

        # Set default apps
        xdg.mimeApps.enable = true;
        xdg.mimeApps.defaultApplications = let
            # this essentially takes each of the types and outputs an attrset of { type = handlers; } if handlers is defined
            genMimeApps = handlers: types: lib.attrsets.optionalAttrs (lib.length handlers != []) (lib.attrsets.genAttrs types (type: handlers));
        in genMimeApps config.js.hm.mime.apps.audio [
            "audio/flac"
            "audio/mpeg"
            "audio/x-vorbis+ogg"
        ] // genMimeApps config.js.hm.mime.apps.browser [
            "text/html"
            "x-scheme-handler/about"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/unknown"
        ] // genMimeApps config.js.hm.mime.apps.docs [
            "application/pdf"
        ] // genMimeApps config.js.hm.mime.apps.image [
            "image/avif"
            "image/bmp"
            "image/gif"
            "image/jpeg"
            "image/png"
            "image/svg+xml"
            "image/tiff"
            "image/webp"
        ] // genMimeApps config.js.hm.mime.apps.mail [
            "x-scheme-handler/mailto"
        ] // genMimeApps config.js.hm.mime.apps.text [
            "application/xml"
            "text/plain"
        ] // genMimeApps config.js.hm.mime.apps.video [
            "video/mp4"
            "video/quicktime"
            "video/x-matroska"
        ] // config.js.hm.mime.override;
    
    };

}

