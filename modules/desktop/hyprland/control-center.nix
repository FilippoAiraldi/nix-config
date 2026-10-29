# Sway Notification Center
# https://github.com/ErikReider/SwayNotificationCenter
# https://man.archlinux.org/man/swaync.5.en
# https://github.com/OlyAhamed/Linux/tree/main/.config/swaync
{
  flake.modules.homeManager.control-center =
    {
      config,
      isVM,
      lib,
      pkgs,
      ...
    }:
    {
      options.desktop.controlCenterCmd = lib.mkOption {
        type = lib.types.str;
        description = "Command to toggle the control center";
      };

      config =
        let
          controlCenterCmd = "swaync-client -t -sw";
        in
        {
          desktop.controlCenterCmd = controlCenterCmd;

          home.packages = with pkgs; [ hyprpicker ];
          systemd.user.services.swaync.Service.Environment = lib.mkIf isVM [ "GSK_RENDERER=cairo" ];
          services.swaync = {
            enable = true;

            settings = {
              cssPriority = "user";
              control-center-margin-bottom = 6;
              control-center-margin-right = 6;
              notification-grouping = false;
              timeout = 6;
              timeout-critical = 9;
              timeout-low = 3;
              transition-time = 0;
              widgets = [
                "buttons-grid"
                "dnd"
                "title"
                "notifications"
              ];
              widget-config = {
                buttons-grid.actions = [
                  {
                    label = "󰏘";
                    command = "${controlCenterCmd}; ${lib.getExe pkgs.hyprpicker}";
                  }
                  {
                    label = "";
                    command = "${controlCenterCmd}; ${config.desktop.settingsCmd}";
                  }
                ];
                dnd = { };
                notifications = { };
                title = { };
              };
            };

            style =
              let
                inherit (config.stylix) fonts;
                inherit (config.lib.stylix) colors;
              in
              with colors.withHashtag;
              ''
                * {
                  all: unset;
                  color: ${base05};
                  font-family: "${fonts.monospace.name}";
                  font-size: ${toString fonts.sizes.desktop}pt;
                }
                .blank-window {
                  background: transparent;
                }
                .body {
                    font-size: 0.8rem;
                }
                .image {
                  margin: 10px 20px 10px 0;
                }
                .summary {
                  font-weight: 800;
                  font-size: 1rem;
                }
                .notification.critical progress,
                .notification.low progress,
                .notification.normal progress {
                  background-color: ${base0E};
                }
                .notification-row {
                  outline: none;
                  margin: 0;
                  padding: 0;
                }

                /* floating notifications */

                .floating-notifications.background .notification-row .notification-background {
                  background: ${base00};
                  border: 1.5px solid ${base07};
                  border-radius: 18px;
                  margin: 16px;
                  padding: 0;
                }
                .floating-notifications.background .notification-row .notification-background .notification {
                  padding: 6px;
                  border-radius: 12px;
                }
                .floating-notifications.background .notification-row .notification-background .notification.critical {
                  border: 2px solid ${base08};
                }
                .floating-notifications.background .notification-row .notification-background .notification .notification-content {
                  margin: 14px;
                }
                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
                  min-height: 3.4em;
                }
                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
                  border-radius: 6px;
                  border: 1px solid ${base02};
                  margin: 6px;
                }
                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
                  color: ${base0E};
                  background: alpha(${base05}, .1);
                }
                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
                  color: ${base00};
                  background: ${base0E};
                }
                .floating-notifications.background .notification-row .notification-background .close-button {
                  margin: 6px;
                  padding: 2px;
                  border-radius: 6px;
                }
                .floating-notifications.background .notification-row .notification-background .close-button:hover {
                  color: ${base0E};
                  background: alpha(${base05}, .1);
                }
                .floating-notifications.background .notification-row .notification-background .close-button:active {
                  color: ${base00};
                  background: ${base0E};
                }

                /* control center */

                .control-center {
                  background: ${base00};
                  border: 2px solid ${base07};
                  border-radius: 6px;
                  margin: 12px;
                  padding: 0;
                }

                /* Title and clear-all button */

                .widget-title {
                  font-size: 1.3em;
                  font-weight: 600;
                  margin: 0;
                  padding: 20px 20px 8px 20px;
                  border-bottom: 1px solid ${base02};
                }
                .widget-title button {
                  border: 1px solid ${base02};
                  border-radius: 6px;
                  padding: 6px 12px;
                  font-weight: 500;
                  min-height: 36px;
                }
                .widget-title button:hover {
                  color: ${base0E};
                  background: alpha(${base05}, .1);
                }
                .widget-title button:active {
                  color: ${base00};
                  background: ${base0E};
                }

                /* Quick settings buttons */

                .widget-buttons-grid {
                  padding: 12px;
                  margin: 0;
                }
                .widget-buttons-grid > flowbox > flowboxchild > button {
                  margin: 4px;
                  border: 1px solid ${base02};
                  border-radius: 6px;
                  min-height: 64px;
                  min-width: 64px;
                }
                .widget-buttons-grid > flowbox > flowboxchild > button:hover {
                  background: alpha(${base05}, .1);
                }
                .widget-buttons-grid > flowbox > flowboxchild > button:hover label {
                  color: ${base0E};
                }
                .widget-buttons-grid > flowbox > flowboxchild > button:active,
                .widget-buttons-grid > flowbox > flowboxchild > button:checked {
                  background: ${base0E};
                  border-color: ${base0E};
                }
                .widget-buttons-grid > flowbox > flowboxchild > button:active label,
                .widget-buttons-grid > flowbox > flowboxchild > button:checked label {
                  color: ${base00};
                }
                .widget-buttons-grid > flowbox > flowboxchild > button label {
                  font-size: 20px;
                }

                /* Do not disturb */

                .widget-dnd {
                  margin: 0;
                  padding: 16px 20px 5px 20px;
                  border-top: 1px solid ${base02};
                  font-size: 1.1rem;
                  font-weight: 500;
                }
                .widget-dnd > switch {
                  background: ${base03};
                  border: 1px solid ${base02};
                  border-radius: 24px;
                  padding: 3px;
                  min-width: 48px;
                  min-height: 28px;
                }
                .widget-dnd > switch:checked {
                  background: ${base0E};
                  border-color: ${base0E};
                }
                .widget-dnd > switch slider {
                  background: ${base05};
                  border-radius: 50%;
                  min-width: 22px;
                  min-height: 22px;
                }

                /* Notifications inside control center */

                .control-center .notification-row {
                  margin: 0;
                  padding: 8px 12px;
                }
                .control-center .notification-row .notification-background {
                  background: ${base01};
                  border: 1px solid ${base02};
                  border-radius: 12px;
                  margin: 4px 0;
                  padding: 0;
                }
                .control-center .notification-row .notification-background:hover {
                  background: alpha(${base05}, .1);
                }
                .control-center .notification-row .notification-background .notification.critical {
                  border-left: 3px solid ${base08};
                  border-radius: 12px;
                }
                .control-center .notification-row .notification-background .notification .notification-content {
                  margin: 0;
                  padding: 14px 16px;
                }
                .control-center .notification-row .notification-background .notification > *:last-child > * {
                  min-height: 0;
                  padding: 8px 12px 12px 12px;
                }
                .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
                  border: 1px solid ${base02};
                  border-radius: 6px;
                  margin: 4px;
                  padding: 10px 18px;
                  font-weight: 500;
                  min-height: 36px;
                }
                .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
                  color: ${base0E};
                  background: alpha(${base05}, .1);
                }
                .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
                  color: ${base00};
                  background: ${base0E};
                }
              '';
          };
        };
    };
}
