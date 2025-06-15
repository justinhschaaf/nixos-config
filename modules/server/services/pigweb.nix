{ inputs, lib, config, pkgs, ... }: {

    imports = [
        inputs.pigweb.nixosModules.default
    ];

    options.js.server.pigweb = {
        enable = lib.mkEnableOption "the PigWebApp server";
        hostName = lib.mkOption { type = lib.types.str; };
        openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
    };

    config = lib.mkIf config.js.server.pigweb.enable {

        sops.secrets."pigweb/pigweb-env".sopsFile = ../../../secrets/server.yaml;

        services.pigweb = {
            enable = true;
            openFirewall = config.js.server.pigweb.openFirewall;
            environmentFile = "/run/secrets/pigweb/pigweb-env";

            config = {
                port = 5555;

                groups = {
                    iam-pigweb-viewer = [ "PigViewer" ];
                    iam-pigweb-editor = [ "PigEditor" "BulkEditor" ];
                    iam-pigweb-admin = [ "BulkAdmin" "UserViewer" "UserAdmin" "LogViewer" ];
                };

                oidc = {
                    auth_uri = "https://${config.js.server.authentik.hostName}/application/o/authorize/";
                    token_uri = "https://${config.js.server.authentik.hostName}/application/o/token/";
                    redirect_uri = "http://${config.js.server.pigweb.hostName}/auth/oidc/response";
                    logout_uri = "https://${config.js.server.authentik.hostName}/application/o/pigweb/end-session/";
                    scopes = [ "openid" "profile" ];
                };
            };
        };

        services.caddy.virtualHosts."${config.js.server.pigweb.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.pigweb.config.port}
            '';

    };

}

