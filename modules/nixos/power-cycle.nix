# daily power-off cycle: full shutdown at night, RTC-triggered power-on in the morning.
{
  flake.modules.nixos.power-cycle =
    { pkgs, ... }:
    let
      powerOnTime = "09:00:00";
      powerOffTime = "21:00:00";
    in
    {
      systemd = {
        # runs on every shutdown and arms the next morning wake
        services.rtc-wake-on-shutdown = {
          description = "Arm RTC wake for next ${powerOnTime} on shutdown";
          wantedBy = [ "multi-user.target" ];
          stopIfChanged = false;
          restartIfChanged = false;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.coreutils}/bin/true";
            ExecStop = pkgs.writeShellScript "arm-rtc-wake" ''
              set -euo pipefail
              now="$(${pkgs.coreutils}/bin/date +%s)"
              target="$(${pkgs.coreutils}/bin/date -d 'today ${powerOnTime}' +%s)"

              # if today's morning is already past (or under some minutes away), use tomorrow
              minutes=5
              if [ "$target" -le "$((now + minutes * 60))" ]; then
                target="$(${pkgs.coreutils}/bin/date -d 'tomorrow ${powerOnTime}' +%s)"
              fi

              echo "Arming RTC wake for $target"
              ${pkgs.util-linux}/bin/rtcwake -m no -t "$target"
            '';
          };
        };

        # timer for powering off
        timers.auto-poweroff = {
          description = "Power off at ${powerOffTime} daily";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-* ${powerOffTime}";
            Persistent = false;
            AccuracySec = "1min";
          };
        };
        services.auto-poweroff = {
          description = "Power off";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.systemd}/bin/systemctl poweroff";
          };
        };
      };
    };
}
