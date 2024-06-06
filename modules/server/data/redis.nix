{ inputs, lib, config, pkgs, ... }: {

    options.js.server.redis = {
        enable = lib.mkEnableOption "Redis, an in-memory database that persists on disk";
        defaultSettings = lib.mkOption { default = {}; };
        ensureApplications = lib.mkOption { type = lib.types.listOf (lib.types.attrsOf lib.types.submodule {
            name = lib.mkOption { type = lib.types.str; };
            port = lib.mkOption { type = lib.types.port; };
            extraConfig = lib.mkOption { default = {}; };
        }); };
        openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config.services.redis = lib.mkIf config.js.server.redis.enable (
        listToAttrs (lib.lists.forEach config.js.server.redis.ensureApplications (
            app: lib.attrsets.recursiveUpdate {
            
                enable = true;
                port = app.port;
                openFirewall = lib.optionals config.js.server.redis.openFirewall;
                
                # add default config and extra config
            } (lib.attrsets.recursiveUpdate config.js.server.redis.defaultSettings app.extraConfig))));

}

