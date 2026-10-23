# Hyprcursor
# https://github.com/hyprwm/hyprcursor
# https://github.com/ndom91/rose-pine-hyprcursor (NOTE: same theme as Stylix)
{
  flake.modules.homeManager.cursor =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.rose-pine-hyprcursor ];
      wayland.windowManager.hyprland.settings.env = [
        {
          _args = [
            "HYPRCURSOR_THEME"
            "rose-pine-hyprcursor"
          ];
        }
        {
          _args = [
            "HYPRCURSOR_SIZE"
            (toString config.stylix.cursor.size)
          ];
        }
      ];
    };
}
