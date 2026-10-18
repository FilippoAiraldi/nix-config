# SDDM + astronaut theme
# https://wiki.nixos.org/wiki/SDDM
# https://github.com/Keyitdev/sddm-astronaut-theme
{
  flake.modules.nixos.display-manager =
    { pkgs, ... }:
    let
      sddm-astronaut = pkgs.sddm-astronaut.override {
        embeddedTheme = "pixel_sakura";
        themeConfig = {
          SessionButtonTextColor = "#2b3340";
          HoverSessionButtonTextColor = "#4a5965";
        };
      };
    in
    {
      environment.systemPackages = [ sddm-astronaut ];

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        extraPackages = [ pkgs.kdePackages.qtmultimedia ];
      };
    };
}
