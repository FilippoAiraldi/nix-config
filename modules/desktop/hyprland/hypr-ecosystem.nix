# Hypr Ecosystem
# https://wiki.hypr.land/Hypr-Ecosystem
{
  flake.modules.homeManager.hypr-ecosystem =
    { config, pkgs, ... }:
    {
      # Hyprcursor
      # https://github.com/hyprwm/hyprcursor
      # https://github.com/ndom91/rose-pine-hyprcursor (NOTE: same theme as Stylix)
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
      # home.packages ++ hyprpicker # https://github.com/hyprwm/hyprpicker
      # services.hyprpaper.enable = true;  # NOTE: crashes; switched to swaybg
    };
}
