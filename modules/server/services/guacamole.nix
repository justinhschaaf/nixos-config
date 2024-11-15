{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.server.guacamole.enable = lib.mkEnableOption "Guacamole, a clientless remote desktop gateway";
        js.server.guacamole.hostName = lib.mkOption { type = lib.types.str; };
        js.server.guacamole.openFirewall = lib.mkOption { default = config.js.server.openFirewall; };
        js.server.guacamole.client.openFirewall = lib.mkOption { default = config.js.server.guacamole.openFirewall; };
        js.server.guacamole.server.openFirewall = lib.mkOption { default = config.js.server.guacamole.openFirewall; };
    };

    config = let
        guacVer = config.services.guacamole-client.package.version;
    in lib.mkIf config.js.server.guacamole.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.guacamole.server.openFirewall [ config.services.guacamole-server.port ]
            ++ lib.optionals config.js.server.guacamole.client.openFirewall [ config.services.tomcat.port ]; # by default, the guac client is hosted on tomcat

        services.guacamole-server.enable = true;
        services.guacamole-client.enable = true;
        services.guacamole-client.settings = {

            guacd-hostname = "localhost";
            guacd-port = config.services.guacamole-server.port;

            # OIDC config
            extension-priority = "*, openid"; # TODO once internal groups are setup, remove "*"
            openid-authorization-endpoint = "https://${config.js.server.authentik.hostName}/application/o/authorize/";
            openid-client-id = "VwcsudUExp6KykaubysVPxemMod2nxzI8c5BvhRd"; # this is apparently fine... https://devforum.okta.com/t/is-authorization-server-id-or-client-id-supposed-to-be-secret/24455
            openid-issuer = "https://${config.js.server.authentik.hostName}/application/o/guacamole/";
            openid-jwks-endpoint = "https://${config.js.server.authentik.hostName}/application/o/guacamole/jwks/";
            openid-redirect-uri = "https://${config.js.server.guacamole.hostName}/";
            openid-username-claim-type = "preferred_username";

        };

        # Create the OIDC add-in
        # adapted from https://github.com/NixOS/nixpkgs/issues/278067
        environment.etc."guacamole/extensions/guacamole-auth-sso-openid-${guacVer}.jar".source = let
            oidcExtension = pkgs.stdenv.mkDerivation {

                name = "guacamole-auth-sso-openid-${guacVer}";

                src = pkgs.fetchurl {
                    url = "https://dlcdn.apache.org/guacamole/${guacVer}/binary/guacamole-auth-sso-${guacVer}.tar.gz";
                    sha256 = "sha256-sO920+Zh+VwtvkahepzoobjUEAcnRY+lXgY1qF03rdg="; # https://www.srihash.org/
                };

                phases = "unpackPhase installPhase";

                unpackPhase = ''
                    tar -xzf $src
                '';

                installPhase = ''
                    mkdir -p $out
                    cp guacamole-auth-sso-${guacVer}/openid/guacamole-auth-sso-openid-${guacVer}.jar $out
                '';

            };
        in "${oidcExtension}/guacamole-auth-sso-openid-${guacVer}.jar";

        services.caddy.virtualHosts."${config.js.server.guacamole.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                reverse_proxy 127.0.0.1:${toString config.services.guacamole-server.port}/guacamole
            '';

    };

}
