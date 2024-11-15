# Most of the work configuring this is adapted from Doosty's Nixpkgs issue
# there's no fucking way my dumb ass would be able to figure this out on my own
# https://github.com/NixOS/nixpkgs/issues/278067
#
# Only ONCE in the Guacamole docs does it mention you must setup a database
# when using it with OIDC. WHY THE FUCK DOES IT NOT COME WITH ONE?
#
# Guacamole has a server module and a client module. The server module can
# stand on it's own, but the client must be hosted through Tomcat. Why couldn't
# they be one software package you host?

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
        pgVer = "42.7.4";

        pgDriverSrc = pkgs.fetchurl {
            url = "https://jdbc.postgresql.org/download/postgresql-${pgVer}.jar";
            sha256 = "sha256-GIl2ch6tjoYn622DidUA3MwMm+vYhSaKMEcYAnSmAx4=";
        };

        pgExtension = pkgs.stdenv.mkDerivation {

            name = "guacamole-auth-jdbc-postgresql-${guacVer}";

            src = pkgs.fetchurl {
                url = "https://dlcdn.apache.org/guacamole/${guacVer}/binary/guacamole-auth-jdbc-${guacVer}.tar.gz";
                sha256 = "sha256-gMygoCB2urrQ3Hx2tg2qiW89m/EL6CcI9CX9Qs5BE5M=";
            };

            phases = "unpackPhase installPhase";

            unpackPhase = ''
                tar -xzf $src
            '';

            installPhase = ''
                mkdir -p $out
                cp -r guacamole-auth-jdbc-${guacVer}/postgresql/* $out
            '';

        };

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

        psql = "${pkgs.postgresql}/bin/psql";
        cat = "${pkgs.coreutils-full}/bin/cat";
    in lib.mkIf config.js.server.guacamole.enable {

        # Open ports
        networking.firewall.allowedTCPPorts = lib.optionals config.js.server.guacamole.server.openFirewall [ config.services.guacamole-server.port ]
            ++ lib.optionals config.js.server.guacamole.client.openFirewall [ config.services.tomcat.port ]; # by default, the guac client is hosted on tomcat

        # Configure guacamole itself

        services.guacamole-server.enable = true;
        services.guacamole-client.enable = true;
        services.guacamole-client.settings = {

            guacd-hostname = "localhost";
            guacd-port = config.services.guacamole-server.port;
            extension-priority = "openid"; # if database login is needed, use "*, openid"

            # Database Config
            postgresql-hostname = "localhost";
            postgresql-database = "guacamole";
            postgresql-username = "guacamole";
            postgresql-password = "";

            # OIDC config
            openid-authorization-endpoint = "https://${config.js.server.authentik.hostName}/application/o/authorize/";
            openid-client-id = "VwcsudUExp6KykaubysVPxemMod2nxzI8c5BvhRd"; # this is apparently fine... https://devforum.okta.com/t/is-authorization-server-id-or-client-id-supposed-to-be-secret/24455
            openid-issuer = "https://${config.js.server.authentik.hostName}/application/o/guacamole/";
            openid-jwks-endpoint = "https://${config.js.server.authentik.hostName}/application/o/guacamole/jwks/";
            openid-redirect-uri = "https://${config.js.server.guacamole.hostName}/";
            openid-username-claim-type = "preferred_username";

        };

        # setup extensions
        environment.etc."guacamole/extensions/guacamole-auth-sso-openid-${guacVer}.jar".source = "${oidcExtension}/guacamole-auth-sso-openid-${guacVer}.jar";
        environment.etc."guacamole/lib/postgresql-${pgVer}.jar".source = pgDriverSrc;
        environment.etc."guacamole/extensions/guacamole-auth-jdbc-postgresql-${guacVer}.jar".source = "${pgExtension}/guacamole-auth-jdbc-postgresql-${guacVer}.jar";

        # Configure DB
        services.postgresql = {
            authentication = ''
                #type database  DBuser  auth-method
                local all       all     trust
                #type database DBuser origin-address auth-method
                host  all      all    127.0.0.1/32   trust
            '';
            enableTCPIP = true;
            ensureDatabases = [ "guacamole" ];
            ensureUsers = [{
                name = "guacamole";
                ensureDBOwnership = true;
            }];
        };

        # Configure services for DB
        systemd.services."guacamole-pgsql-schema-import" = {
            enable = true;
            requires = [ "postgresql.service" ];
            after = [ "postgresql.service" ];
            wantedBy = [ "tomcat.service" "multi-user.target" ]; # ??
            script = ''
                echo "[guacamole-bootstrapper] Info: checking if database 'guacamole' exists but is empty..."
                output=$(${psql} -U guacamole -c "\dt" 2>&1)
                if [[ $output == "Did not find any relations." ]]; then
                    echo "[guacamole-bootstrapper] Info: installing guacamole postgres database schema..."
                    ${cat} ${pgExtension}/schema/*.sql | ${psql} -U guacamole -d guacamole -f -
                fi
            '';
        };

        systemd.services."tomcat" = {
            requires = [ "postgresql.service" ];
            after = [ "postgresql.service" ];
        };

        # use the rewrite directive to work around tomcat
        # https://caddyserver.com/docs/caddyfile/directives/rewrite
        # https://caddy.community/t/reverse-proxy-to-a-upstream-server-with-a-path-or-subfolder/15335
        services.caddy.virtualHosts."${config.js.server.guacamole.hostName}".extraConfig =
            lib.mkIf config.js.server.caddy.enable ''
                rewrite * /guacamole{uri}
                reverse_proxy 127.0.0.1:${toString config.services.tomcat.port}
            '';

    };

}
