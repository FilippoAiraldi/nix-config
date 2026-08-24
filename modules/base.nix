{ config, ... }:
let
  inherit (config.flake.modules) generic nixos homeManager;
  commonImports = [
    generic.homeManagerIntegration
    generic.nixSettings
    generic.primaryUser
    generic.primaryUserHome
    generic.profile
  ];
in
{
  flake.modules.generic.homeManagerIntegration = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ homeManager.base ];
    };
  };

  flake.modules.nixos.base = {
    imports = commonImports ++ [
      nixos.bash
      nixos.boot
      nixos.dns
      nixos.locale
      nixos."network-filesystem"
      nixos.networking
      nixos.nixvim
      nixos.packages
      nixos."power-cycle"
      nixos.services
      nixos.users
    ];
  };

  flake.modules.homeManager.base = {
    imports = [
      generic.profile
      homeManager.bash
      homeManager.fzf
      homeManager.git
      homeManager.packages
      homeManager.zellij
    ];
  };
}
