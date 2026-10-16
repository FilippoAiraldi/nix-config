{ config, ... }:
{
  flake.modules = {
    nixos.fonts.home-manager.sharedModules = [ config.flake.modules.homeManager.fonts ];

    homeManager.fonts =
      { config, ... }:
      let
        inherit (config.profile.appearance.fonts) ui monospace;
      in
      {
        fonts.fontconfig.defaultFonts = {
          sansSerif = [ ui.family ];
          monospace = [ monospace.family ];
        };
        home.packages = [
          ui.package
          monospace.package
        ];
      };
  };
}
