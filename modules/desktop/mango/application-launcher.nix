# Fuzzel
# https://man.archlinux.org/man/fuzzel.ini.5.en
{ config, ... }:
let
  inherit (config.theme) colorFmt colors;
in
{
  flake.modules.homeManager.application-launcher =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mango.appLauncherCmd = lib.mkOption {
        type = lib.types.str;
        description = "Command to spawn the app launcher (e.g., `rofi -show drun`)";
      };

      config =
        let
          pkg = pkgs.fuzzel;
          inherit (config.profile.appearance.fonts) monospace;
        in
        {
          mango.appLauncherCmd = lib.getExe pkg;

          programs.fuzzel = {
            enable = true;
            package = pkg;
            settings = {
              border.width = 2;
              colors = {
                background = colorFmt.rgba colors.ink-black "cc";
                border = colorFmt.rgba colors.baby-blue-ice "ff";
                selection = colorFmt.rgba colors.space-indigo "cc";
                text = colorFmt.rgba colors.lavender "ff";
                selection-text = colorFmt.rgba colors.lavender "ff";
              };
              key-bindings = {
                delete-line-forward = "none";
                next = "Down Control+j";
                prev = "Up Control+k";
              };
              main = {
                font = "${monospace.family}:size=${toString monospace.size}";
                use-bold = "yes";
              };
            };
          };
        };
    };
}
