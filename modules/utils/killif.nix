{ inputs, lib, config, pkgs, system, ... }: {

    options.js.killif = {
        enable = lib.mkEnableOption "automatic killing of misbehaving processes";
        targets = lib.mkOption {
            type = lib.types.attrsOf lib.types.ints.positive;
            default = {};
            description = "Which processes should be killed when exceeding what memory threshold, in MB.";
            example = { "gunicorn: worke" = 1500; };
        };
    };

    config = lib.mkIf config.js.killif.enable {

        # here, we use the mapAttrs' function to update both the name and value
        # of the targets attrset to be used to define the systemd service. the
        # value is converted into the options for the service, while the name
        # must be sanitized of spaces and special characters or else the build
        # will fail. the nix language doesn't really have a good way of
        # replacing all the special characters in a string, so the function that
        # updates the name:
        # - uses builtins.match to find up to 4 alphanumeric chunks (that's what
        #   the disgusting regex is for, for whatever reason the regex doesn't
        #   search globally, it must match the entire string)
        # - adds the list of chunks to the end of a list containing "killif-" to
        #   clarify that this service is killing any process which matches
        # - concats all the strings in the list
        # this took maybe 2-3 hours to figure out
        systemd.services = lib.attrsets.mapAttrs' (name: value: lib.attrsets.nameValuePair
            (lib.strings.concatStrings (["killif-"] ++ (builtins.match "[^[:alnum:]]*([[:alnum:]]+)[^[:alnum:]]*([[:alnum:]]*)[^[:alnum:]]*([[:alnum:]]*)[^[:alnum:]]*([[:alnum:]]*)[^[:alnum:]]*" name)))
            {
                script = "${inputs.self.outputs.packages.${system}.killif}/bin/killif \"${name}\" ${builtins.toString value}";
                serviceConfig = {
                    Type = "exec"; # https://man.archlinux.org/man/systemd.service.5#OPTIONS
                    User = "root";
                    Restart = "always";
                };
            }) config.js.killif.targets;

    };

}
