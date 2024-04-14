{ inputs, lib, osConfig, config, pkgs, ... }: {

    # https://nlewo.github.io/nixos-manual-sphinx/development/option-types.xml.html
    options = {
        js.hm.mime.enable = lib.mkOption { default = osConfig.js.programs.desktop.enable; };
        js.hm.mime.apps.audio = lib.mkOption { type = lib.types.listOf lib.types.str; };
        js.hm.mime.apps.browser = lib.mkOption { type = lib.types.listOf lib.types.str; };
        js.hm.mime.apps.docs = lib.mkOption { type = lib.types.listOf lib.types.str; };
        js.hm.mime.apps.image = lib.mkOption { type = lib.types.listOf lib.types.str; };
        js.hm.mime.apps.mail = lib.mkOption { type = lib.types.listOf lib.types.str; };
        js.hm.mime.apps.text = lib.mkOption { type = lib.types.listOf lib.types.str; };
        js.hm.mime.apps.video = lib.mkOption { type = lib.types.listOf lib.types.str; };
        js.hm.mime.override = lib.mkOption { default = {}; };
    };

    config = lib.mkIf config.js.hm.mime.enable {

        # Set default apps
        xdg.mimeApps.enable = true;
        xdg.mimeApps.defaultApplications = {} // (
            if config.js.hm.mime.apps.audio != []
            then {
                "audio/flac" = config.js.hm.mime.apps.audio;
                "audio/mpeg" = config.js.hm.mime.apps.audio;
                "audio/x-vorbis+ogg" = config.js.hm.mime.apps.audio;
            } else {}) // (
            if config.js.hm.mime.apps.browser != []
            then {
                "text/html" = config.js.hm.mime.apps.browser;
                "x-scheme-handler/about" = config.js.hm.mime.apps.browser;
                "x-scheme-handler/http" = config.js.hm.mime.apps.browser;
                "x-scheme-handler/https" = config.js.hm.mime.apps.browser;
                "x-scheme-handler/unknown" = config.js.hm.mime.apps.browser;
            } else {}) // (
            if config.js.hm.mime.apps.docs != []
            then {
                "application/pdf" = config.js.hm.mime.apps.docs;
            } else {}) // (
            if config.js.hm.mime.apps.image != []
            then {
                "image/avif" = config.js.hm.mime.apps.image;
                "image/bmp" = config.js.hm.mime.apps.image;
                "image/gif" = config.js.hm.mime.apps.image;
                "image/jpeg" = config.js.hm.mime.apps.image;
                "image/png" = config.js.hm.mime.apps.image;
                "image/svg+xml" = config.js.hm.mime.apps.image;
                "image/tiff" = config.js.hm.mime.apps.image;
                "image/webp" = config.js.hm.mime.apps.image;
            } else {}) // (
            if config.js.hm.mime.apps.mail != []
            then {
                "x-scheme-handler/mailto" = config.js.hm.mime.apps.mail;
            } else {}) // (
            if config.js.hm.mime.apps.text != []
            then {
                "application/xml" = config.js.hm.mime.apps.text;
                "text/plain" = config.js.hm.mime.apps.text;
            } else {}) // (
            if config.js.hm.mime.apps.video != []
            then {
                "video/mp4" = config.js.hm.mime.apps.video;
                "video/quicktime" = config.js.hm.mime.apps.video;
                "video/x-matroska" = config.js.hm.mime.apps.video;
            } else {}) // config.js.hm.mime.override;
    
    };

}
