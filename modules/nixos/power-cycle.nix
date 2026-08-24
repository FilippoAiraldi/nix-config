# daily power-off cycle: full shutdown at 22:00, RTC-triggered power-on at 09:00.
{
  flake.modules.nixos."power-cycle" =
    { pkgs, ... }:
    {
      systemd.timers.auto-poweroff = {
        description = "Power off at 22:00 daily";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 22:00:00";
          Persistent = false;
          AccuracySec = "1min";
        };
      };

      systemd.services.auto-poweroff = {
        description = "Schedule RTC wake for 09:00 and power off";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "auto-poweroff" ''
            set -euo pipefail
            wake_time="$(${pkgs.coreutils}/bin/date -d 'tomorrow 09:00:00' +%s)"
            echo "Scheduling RTC wake for $wake_time"
            ${pkgs.util-linux}/bin/rtcwake -m off -t "$wake_time"
          '';
        };
      };
    };
}
