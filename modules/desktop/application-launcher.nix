# Fuzzel
# https://man.archlinux.org/man/fuzzel.ini.5.en
{
  flake.modules.homeManager.application-launcher =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.desktop = {
        appLauncherName = lib.mkOption {
          type = lib.types.str;
          description = "Name of the app launcher (e.g., `rofi`)";
        };
        appLauncherCmd = lib.mkOption {
          type = lib.types.str;
          description = "Command to spawn the app launcher (e.g., `rofi -show drun`)";
        };
      };
      config =
        let
          inherit (config.profile.appearance) border;
          inherit (config.lib.stylix) colors;
          appLauncherName = "fuzzel";
          pkg = pkgs.${appLauncherName};
        in
        {
          desktop = {
            appLauncherCmd = lib.getExe pkg;
            appLauncherName = appLauncherName;
          };

          programs.${appLauncherName} = {
            enable = true;
            package = pkg;
            settings = {
              border = {
                radius = border.radius;
                width = border.width;
              };
              colors = {
                background = lib.mkForce "${colors.base00}e3";
                border = lib.mkForce "${colors.base0E}ff";
                selection = lib.mkForce "${colors.base02}cc";
              };
              key-bindings = {
                delete-line-forward = "none";
                next = "Down Control+j";
                prev = "Up Control+k";
              };
              main.use-bold = "yes";
            };
          };
        };
    };
}
