# daily power-off cycle: full shutdown at night, RTC-triggered power-on in the morning.
# use `poweroff-force` to bypass the power-cycle and switch the host off for good.
{
  flake.modules.nixos.power-cycle =
    { pkgs, ... }:
    let
      powerOnTime = "09:00:00";
      powerOffTime = "21:00:00";

      forceFlagFile = "/run/poweroff-force";

      armRtcWake = pkgs.writeShellScript "arm-rtc-wake" ''
        set -euo pipefail

        # poweroff-force was requested: consume the flag, clear any alarm armed earlier
        # and skip arming a new one
        if [ -e "${forceFlagFile}" ]; then
          ${pkgs.coreutils}/bin/rm -f "${forceFlagFile}"
          echo "poweroff-force requested, disabling RTC wake"
          ${pkgs.util-linux}/bin/rtcwake -m disable
          exit 0
        fi

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

      poweroffForce = pkgs.writeShellScriptBin "poweroff-force" ''
        set -euo pipefail

        if [ "$(${pkgs.coreutils}/bin/id -u)" -ne 0 ]; then
          echo "poweroff-force must run as root (use sudo)" >&2
          exit 1
        fi

        ${pkgs.coreutils}/bin/touch "${forceFlagFile}"
        echo "Forced poweroff: RTC wake will not be armed."
        if ! ${pkgs.systemd}/bin/systemctl poweroff; then
          # shutdown was refused (a block-mode inhibitor, for example); undo the flag
          ${pkgs.coreutils}/bin/rm -f "${forceFlagFile}"
          echo "poweroff did not start; wake will be armed at the next shutdown" >&2
          exit 1
        fi
      '';
    in
    {
      environment.systemPackages = [ poweroffForce ];

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
            ExecStop = armRtcWake;
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
