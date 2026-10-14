# Mango Windows Manager
# https://mangowm.github.io/docs
# https://wiki.nixos.org/wiki/Mango
{ inputs, config, ... }:
let
  hmModules = config.flake.modules.homeManager;
in
{
  flake.modules.nixos.mango =
    { pkgs, ... }:
    {
      imports = [ inputs.mangowm.nixosModules.mango ];
      programs.mango.enable = true;
      home-manager.sharedModules = [ hmModules.mango ];
    };

  flake.modules.homeManager.mango =
    { pkgs, ... }:
    {
      imports = [ inputs.mangowm.hmModules.mango ];

      home.packages = with pkgs; [
        foot
        fuzzel
      ];

      wayland.windowManager.mango = {
        enable = true;
      };
    };
}
