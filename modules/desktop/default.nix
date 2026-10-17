{ config, ... }:
let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.desktop = {
    home-manager.sharedModules = [ homeManager.desktop ];
  };

  flake.modules.homeManager.desktop = {
    imports = [
      homeManager.application-launcher
      homeManager.terminal-emulator
    ];
  };
}
