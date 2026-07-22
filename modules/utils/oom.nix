{ inputs, lib, config, pkgs, system, ... }: {

    options.js.oom.enable = lib.mkEnableOption "OOM killer" // { default = true; };

    config.services.earlyoom = lib.mkIf config.js.oom.enable {
        enable = true;
        extraArgs = [
            "--prefer"
            "^gunicorn: worke$" # always try to kill authentik
        ];
    };

}
