# Hyprlock
# https://wiki.hypr.land/Hypr-Ecosystem/hyprlock
{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.lock-screen =
    { config, ... }:
    {
      # https://mynixos.com/home-manager/option/programs.hyprlock.enable
      security.pam.services.hyprlock = { };

      # load homeManager.lock-screen with special arg `isVM`
      home-manager.extraSpecialArgs = {
        inherit (config) isVM;
      };
      home-manager.sharedModules = [ homeManager.lock-screen ];
    };

  flake.modules.homeManager.lock-screen =
    {
      isVM,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.stylix) fonts;
      inherit (config.lib.stylix) colors;
      hyprlock-software = pkgs.symlinkJoin {
        name = "hyprlock-software";
        paths = [ pkgs.hyprlock ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hyprlock --set LIBGL_ALWAYS_SOFTWARE 1
        '';
      };
    in
    {
      options.desktop.lockScreenCmd = lib.mkOption {
        type = lib.types.str;
        description = "Command to launch the lock screen";
      };

      config = {
        desktop.lockScreenCmd = "hyprlock";

        programs.hyprlock = {
          enable = true;
          package = lib.mkIf isVM hyprlock-software;

          settings = with colors; with fonts; {
            general = {
              screencopy_mode = 1;
            };

            background = [
              {
                monitor = "";
                path = "screenshot";
                blur_passes = 2;
                blur_size = 8;
              }
            ];

            # day-month-date
            label = [
              {
                monitor = "";
                text = ''cmd[update:60000] date +"%A, %B %d"'';
                color = "rgba(${base05}b3)";
                font_family = "${monospace.name}";
                font_size = 25;
                position = "0, 250";
              }
              # time
              {
                monitor = "";
                text = ''cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"'';
                color = "rgba(${base05}b3)";
                font_family = "${monospace.name}";
                font_size = 100;
                position = "0, 150";
              }
              # user
              {
                monitor = "";
                text = "$USER";
                color = "rgba(${base05}cc)";
                font_family = "${monospace.name}";
                font_size = 18;
                position = "0, -50";
              }
              # suspend
              {
                monitor = "";
                text = ''<span>󰤄<span size="xx-small"> </span></span>'';
                color = "rgba(${base05}99)";
                font_family = "${monospace.name}";
                font_size = 50;
                position = "-200, 100";
                valign = "bottom";
                onclick = "systemctl suspend";
              }
              # reboot
              {
                monitor = "";
                text = ''<span>󰜉<span size="xx-small"> </span></span>'';
                color = "rgba(${base05}99)";
                font_family = "${monospace.name}";
                font_size = 50;
                position = "0, 100";
                valign = "bottom";
                onclick = "systemctl reboot";
              }
              # power off
              {
                monitor = "";
                text = ''<span>󰐥<span size="xx-small"> </span></span>'';
                color = "rgba(${base05}99)";
                font_family = "${monospace.name}";
                font_size = 50;
                position = "200, 100";
                valign = "bottom";
                onclick = "systemctl poweroff";
              }
            ];
            # user-box
            shape = [
              {
                monitor = "";
                size = "300, 60";
                color = "rgba(${base05}1a)";
                rounding = -1;
                position = "0, -50";
              }
            ];
            # input field for password
            input-field = [
              {
                monitor = "";
                placeholder_text = ''<i><span foreground="##${base05}99">Password</span></i>'';
                check_color = "rgb(${base0A})";
                fail_color = "rgb(${base08})";
                font_color = "rgb(${base05})";
                inner_color = "rgb(${base00})";
                outer_color = "rgb(${base03})";
                font_family = "${monospace.name}";
                size = "300, 60";
                position = "0, -130";
              }
            ];
          };
        };
      };
    };
}
