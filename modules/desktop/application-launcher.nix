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
        appLauncherCmd = lib.mkOption {
          type = lib.types.str;
          description = "Command to toggle the app launcher";
        };
      };
      config =
        let
          inherit (config.profile.appearance) border;
          inherit (config.lib.stylix) colors;
          name = "fuzzel";
          pkg = pkgs.${name};
        in
        {
          desktop = {
            appLauncherCmd = "pkill ${name} || ${lib.getExe pkg}";
          };

          programs.${name} = {
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
