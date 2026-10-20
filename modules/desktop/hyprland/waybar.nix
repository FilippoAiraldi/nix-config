# Waybar
# https://wiki.nixos.org/wiki/Waybar
# https://github.com/Alexays/Waybar/wiki
# https://www.nerdfonts.com/cheat-sheet
{
  flake.modules.homeManager.waybar =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.stylix) fonts;
      inherit (config.lib.stylix) colors;
    in
    {
      programs.waybar = {
        enable = true;
        systemd.enable = true;

        settings = {
          mainBar = {
            layer = "top";
            margin-top = 7;
            margin-bottom = 1;
            width = 2000; # instead of margin-left/right
            height = 36;

            modules-left = [
              "group/power-group"
              "cpu"
              "memory"
            ];
            modules-center = [ "hyprland/workspaces" ];
            modules-right = [
              "hyprland/language"
              "network"
              "clock#date"
              "clock#time"
            ];

            "clock#date" = {
              format = "{:L%a %d/%m}";
              tooltip-format = "<tt><small>{calendar}</small></tt>";
              calendar = {
                mode = "year";
                mode-mon-col = 3;
                weeks-pos = "right";
                on-scroll = -1;
                on-click-right = "mode";
                format = {
                  months = "<span color='#${colors.base06}'><b>{}</b></span>";
                  days = "<span color='#${colors.base05}'><b>{}</b></span>";
                  weeks = "<span color='#${colors.base0C}'><b>W{}</b></span>";
                  weekdays = "<span color='#${colors.base0A}'><b>{}</b></span>";
                  today = "<span color='#${colors.base08}'><b><u>{}</u></b></span>";
                };
              };
              actions = {
                on-click-right = "mode";
                on-scroll-up = "shift_up";
                on-scroll-down = "shift_down";
              };
            };
            "clock#time" = {
              format = "{:L%H:%M}";
              timezone-tooltip-format = "{:%H:%M %Z}";
              timezones = [
                "CET"
                "GMT"
                "UTC"
              ];
              tooltip-format = "{tz_list}";
            };
            cpu = {
              format = "{usage:>2}% ";
              format-alt = "{load} ";
            };
            "custom/lock" = {
              format = "󰍁";
              tooltip = true;
              tooltip-format = "Lock";
              # on-click = "hyprlock"; # TODO: install hyprlock
            };
            "custom/power" = {
              format = "";
              tooltip = true;
              tooltip-format = "Shutdown";
              on-click = "${pkgs.systemd}/bin/systemctl poweroff";
            };
            "custom/quit" = {
              format = "󰗼";
              tooltip = true;
              tooltip-format = "Quit Hyprland";
              on-click = lib.getExe pkgs.hyprshutdown;
            };
            "custom/reboot" = {
              format = "󰜉";
              tooltip = true;
              tooltip-format = "Reboot";
              on-click = "reboot";
            };
            "group/power-group" = {
              orientation = "horizontal";
              drawer = {
                children-class = "not-power";
                transition-duration = 0;
                transition-left-to-right = true;
              };
              modules = [
                "custom/power"
                "custom/quit"
                "custom/lock"
                "custom/reboot"
              ];
            };
            "hyprland/language" = {
              format = "󰌌 {}";
              format-en = "EN";
              format-it = "IT";
              keyboard-name = "at-translated-set-2-keyboard";
            };
            memory = {
              format = "{used:0.1f}/{total:0.0f}GiB";
              format-alt = "{percentage}% ";
              tooltip-format = "{used:0.1f}GiB used\n{avail:0.1f}GiB avail\n{total:0.1f}GiB total\n{swapUsed:0.1f}GiB swap used\n{swapAvail:0.1f}GiB swap avail\n{swapTotal:0.1f}GiB swap total";
            };

            network = {
              interval = 5;
              format-wifi = "{icon}";
              format-icons = [
                "󰤯"
                "󰤟"
                "󰤢"
                "󰤥"
                "󰤨"
              ];
              format-ethernet = "󰀂";
              format-alt = "󱛇";
              format-disconnected = "󰖪";
              tooltip-format-wifi = "{icon} {essid}\n{ipaddr}\n⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}";
              tooltip-format-ethernet = "󰀂  {ifname}\n{ipaddr}\n⇣{bandwidthDownBytes} ⇡{bandwidthUpBytes}";
              tooltip-format-disconnected = "Disconnected";
              # on-click = "nm-connection-editor"; # TODO: install connection editor
            };

            "hyprland/workspaces" = {
              format = "{icon}";
              format-icons = {
                # "1" = "○";
                # "2" = "○";
                # "3" = "○";
                # "4" = "○";
                # "5" = "○";
                # active = "●";
                "1" = "";
                "2" = "";
                "3" = "";
                "4" = "";
                "5" = "";
                active = "";
                "6" = "6";
                "7" = "7";
                "8" = "8";
                "9" = "9";
                urgent = "◆";
              };
              on-click = "activate";
              persistent-workspaces = {
                "*" = 5;
              };
            };
          };
        };

        style = with colors.withHashtag; ''
          * {
            color: ${base05};
            font-family: "${fonts.monospace.name}";
            font-size: ${toString fonts.sizes.desktop}pt;
          }
          tooltip {
            background: ${base00};
            border: 1.5px solid ${base0E};
          }
          tooltip label {
            color: ${base05};
          }
          window#waybar {
            background: alpha(${base00}, 0.9);
            border: 1.5px solid ${base07};
            border-radius: 18px;
          }

          /* add margin matching bar's border-radius */
          .modules-left {
            margin-left: -5px;
          }
          .modules-right {
            margin-right: 6px;
          }

          /* spacing between modules */
          #clock,
          #language,
          #memory,
          #network,
          #power-group,
          #workspaces {
            margin: 0 6px;
            padding: 0 6px;
          }
          #cpu {
            margin-right: 6px;
          }

          /* spacing between power drawer's modules + custom color for hyprland logo */
          #custom-power {
            color: ${base0C};
            font-weight: 900;
          }
          #custom-lock,
          #custom-power,
          #custom-quit,
          #custom-reboot {
            margin: 4px 3px;
            padding: 0;
            min-width: 26px;
            border-radius: 6px;
          }
          #custom-lock:hover,
          #custom-power:hover,
          #custom-quit:hover,
          #custom-reboot:hover {
            color: ${base0E};
            background: alpha(${base05}, 0.1);
          }

          #workspaces button {
            min-height: 0;
            min-width: 0;
            border: none;
            box-shadow: none;
            text-shadow: none;
            background: transparent;
            padding: 0 10px;
          }
        '';
      };
    };
}
