{ inputs, config, pkgs, ... }:

{

    # Automatically run updates based on the GitHub repo instead of system.autoUpgrade
    # systemd timers recommended over cron by the NixOS Wiki
    # https://nixos.wiki/wiki/Systemd/Timers

    systemd.timers."js-autoupdate" = {
        description = "Pulls the latest system updates from GitHub daily.";
        wantedBy = [ "timers.target" ]; # See https://unix.stackexchange.com/questions/427346/im-writing-a-systemd-timer-what-value-should-i-use-for-wantedby
        timerConfig = {
            OnCalendar = "12:00:00";
            Unit = "js-autoupdate.service";
            Persistent = true;
        };
    };

    systemd.services."js-autoupdate" = {
        script = "../scripts/update.sh"; # TODO pass config location to the script
        serviceConfig = {
            Type = "oneshot";
            User = "root";
        };
    };

    # We need git and libnotify for this to work
    # yes it's declared elsewhere, no i don't care
    environment.systemPackages = with pkgs; [
        git
        libnotify
    ];

}
