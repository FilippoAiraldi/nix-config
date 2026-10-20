# Hypr Ecosystem
# https://wiki.hypr.land/Hypr-Ecosystem
{
  flake.modules.homeManager.hypr-ecosystem =
    { pkgs, ... }:
    {
      # Hyprcursor
      # https://github.com/hyprwm/hyprcursor
      # https://github.com/ndom91/rose-pine-hyprcursor
      home.pointerCursor = {
        enable = true;
        name = "rose-pine-hyprcursor";
        package = pkgs.rose-pine-hyprcursor;
        size = 24;
        hyprcursor.enable = true;
      };

      home.packages = with pkgs; [
        # hyprpicker # https://github.com/hyprwm/hyprpicker (TODO: broken in the VM)
        # hyprshutdown # https://github.com/hyprwm/hyprpicker (TODO: broken in the VM)
      ];
      # home.packages ++ hyprpicker # https://github.com/hyprwm/hyprpicker
      # services.hyprpaper.enable = true;  # NOTE: crashes; switched to swaybg
    };
}
