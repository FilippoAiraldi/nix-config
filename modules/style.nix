{ config, inputs, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.style =
    { config, pkgs, ... }:
    let
      inherit (config.profile.appearance.fonts) monospace sansSerif sizes;
    in
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      home-manager.sharedModules = [ homeManager.style ];

      stylix = {
        enable = true;

        # theme, cursor and fonts
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        cursor = {
          name = "BreezeX-RosePine-Linux";
          package = pkgs.rose-pine-cursor;
          size = 24;
        };
        fonts = {
          monospace = {
            package = monospace.package;
            name = monospace.name;
          };
          sansSerif = {
            package = sansSerif.package;
            name = sansSerif.name;
          };
          sizes = {
            applications = sizes.applications;
            desktop = sizes.desktop;
          };
        };

        # wallpaper
        image = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/orangci/walls-catppuccin-mocha/7bfdf10d16ad3a689f9f0cf3a0930da3d1a245a8/storm.jpg";
          hash = "sha256-g1bjruWWBjFzhVskgqhW+mtgv3BN8azgvULKDONM4WQ=";
        };

        # system-level per-target options
        targets.plymouth.enable = false;
      };
    };

  flake.modules.homeManager.style = {
    # HomeManager-level per-target options
    stylix.targets = {
      hyprland.hyprpaper.enable = false; # NOTE: crashes; use swaybg instead
      hyprpaper.enable = false;
      rofi.enable = false;
      waybar.enable = false; # done manually
      hyprlock.enable = false;
    };
  };
}
